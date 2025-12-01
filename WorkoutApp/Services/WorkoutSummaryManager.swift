//
//  WorkoutSummaryManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 21/11/25.
//

import Foundation
import HealthKit
import SwiftData

struct DaySummary {
    var totalDuration: TimeInterval = 0
    var activeCalories: Double = 0
    var basalCalories: Double = 0
    var totalCalories: Double = 0
    var avgHeartRate: Double = 0
    var workoutCount: Int = 0
}

@MainActor
class WorkoutSummaryManager: ObservableObject {
    private let healthStore = HKHealthStore()
    private var workoutService: WorkoutSessionService?
    
    @Published var weeklySummaries: [Int: DaySummary] = [:]
    @Published var isLoading: Bool = false
    
    // ✨ Setup with modelContext
    func setupService(modelContext: ModelContext) {
        let storage = WorkoutSessionStorage(modelContext: modelContext)
        self.workoutService = WorkoutSessionService(storage: storage)
    }
    
    private let allowedSourceBundleIDs: Set<String> = [
        "dawnhazed.WorkoutApp2",
        "dawnhazed.WorkoutApp2.watchkitapp",
        "dawnhazed.WorkoutApp2.watchkitapp.watchkitextension"
    ]
    
    // MARK: - Public API
    
    func fetchWeeklySummary(dailyMenus: [DailyMenu]) async {
        await MainActor.run { isLoading = true }
        
        var summaries: [Int: DaySummary] = [:]
        
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = weekday == 1 ? -6 : -(weekday - 2)
        
        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today) else {
            await MainActor.run { isLoading = false }
            return
        }
        
        for dayIndex in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayIndex, to: monday) else {
                continue
            }
            
            let dayNumber = dayIndex + 1
            
            guard let menu = dailyMenus.first(where: { $0.dayNumber == dayNumber }) else {
                summaries[dayIndex] = DaySummary()
                continue
            }
            
            let summary = await fetchDaySummary(for: date, category: menu.category)
            summaries[dayIndex] = summary
        }
        
        await MainActor.run { [summaries] in
            self.weeklySummaries = summaries
            self.isLoading = false
        }
    }
    
   
    private func fetchDaySummary(for date: Date, category: MenuCategory) async -> DaySummary {
            if case .rest = category {
                return DaySummary()
            }
            
            // ✨ Use SwiftData service
            if let savedSummary = workoutService?.getAggregatedSummary(for: date),
               savedSummary.workoutCount > 0 {
                print("📊 Using saved session data: \(savedSummary.workoutCount) workout(s)")
                return savedSummary
            }
        
        // ✨ FALLBACK: Query HealthKit (for workouts saved before this feature)
        print("📊 No saved sessions, querying HealthKit for \(date)")
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return DaySummary()
        }
        
        // Determine workout types based on category
        let workoutTypes: [HKWorkoutActivityType]
        switch category {
        case .cardio:
            workoutTypes = [
                .walking, .running, .cycling, .swimming,
                .basketball, .tennis, .badminton, .volleyball, .soccer
            ]
        case .strengthGeneric, .strengthLower, .strengthUpper:
            workoutTypes = [
                .traditionalStrengthTraining,
                .functionalStrengthTraining
            ]
        case .rest:
            return DaySummary()
        }
        
        // Build predicates
        let datePredicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )
        
        let typePredicates = workoutTypes.map {
            HKQuery.predicateForWorkouts(with: $0)
        }
        let typePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: typePredicates)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            datePredicate,
            typePredicate
        ])
        
        // Query HealthKit
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: compoundPredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { [allowedSourceBundleIDs] _, samples, error in
                
                if let error = error {
                    print("❌ Error fetching workouts from HealthKit: \(error.localizedDescription)")
                    continuation.resume(returning: DaySummary())
                    return
                }
                
                guard let samples = samples else {
                    print("⚠️ No workout samples found in HealthKit")
                    continuation.resume(returning: DaySummary())
                    return
                }
                
                let workouts = samples as! [HKWorkout]
                
                // Filter by allowed bundle IDs
                let filtered = workouts.filter {
                    allowedSourceBundleIDs.contains($0.sourceRevision.source.bundleIdentifier)
                }
                
                if filtered.isEmpty {
                    print("⚠️ No workouts from allowed sources in HealthKit")
                    continuation.resume(returning: DaySummary())
                    return
                }
                
                print("📊 Found \(filtered.count) workout(s) in HealthKit for \(startOfDay)")
                for workout in filtered {
                    print("   • \(workout.workoutActivityType.displayName) at \(workout.startDate)")
                }
                
                Task {
                    let summary = await self.aggregateWorkoutsFromHealthKit(filtered)
                    continuation.resume(returning: summary)
                }
            }
            
            healthStore.execute(query)
        }
    }

    // MARK: - Aggregate from HealthKit (Fallback)

    private func aggregateWorkoutsFromHealthKit(_ workouts: [HKWorkout]) async -> DaySummary {
        var summary = DaySummary()
        var allHeartRates: [Double] = []
        
        for workout in workouts {
            summary.totalDuration += workout.duration
            summary.workoutCount += 1
            
            if let basalEnergy = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!)?.sumQuantity()?.doubleValue(for: .kilocalorie()){
                summary.basalCalories += basalEnergy
            }
            
            if let activeEnergy = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!)?.sumQuantity()?.doubleValue(for: .kilocalorie()) {
                summary.activeCalories += activeEnergy
            }
            
            let totalEnergy = summary.activeCalories + summary.basalCalories
            summary.totalCalories += totalEnergy
            
            if let avgHR = await fetchAverageHeartRate(for: workout) {
                allHeartRates.append(avgHR)
            }
        }
        
        if !allHeartRates.isEmpty {
            summary.avgHeartRate = allHeartRates.reduce(0, +) / Double(allHeartRates.count)
        }
        
        return summary
    }

    // MARK: - Energy Queries (using HKStatisticsQuery)
    
    private func loadTotalActiveEnergy(start: Date, end: Date) async -> Double {
        guard let type = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return 0
        }
        
        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
                withStart: start,
                end: end,
                options: .strictStartDate
            )
            
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    print("❌ Error fetching active energy: \(error.localizedDescription)")
                    continuation.resume(returning: 0)
                    return
                }
                
                let kcal = statistics?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: kcal)
            }
            
            self.healthStore.execute(query)
        }
    }
    
    private func loadTotalBasalEnergy(start: Date, end: Date) async -> Double {
        guard let type = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned) else {
            return 0
        }
        
        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
                withStart: start,
                end: end,
                options: .strictStartDate
            )
            
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    print("❌ Error fetching basal energy: \(error.localizedDescription)")
                    continuation.resume(returning: 0)
                    return
                }
                
                let kcal = statistics?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: kcal)
            }
            
            self.healthStore.execute(query)
        }
    }
    
    // MARK: - Heart Rate Helper
    
    private func fetchAverageHeartRate(for workout: HKWorkout) async -> Double? {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return nil
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate,
            options: .strictStartDate
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, statistics, error in
                if let error = error {
                    print("❌ Error fetching heart rate: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let avgQuantity = statistics?.averageQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let avg = avgQuantity.doubleValue(
                    for: HKUnit.count().unitDivided(by: .minute())
                )
                continuation.resume(returning: avg)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Formatting
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}


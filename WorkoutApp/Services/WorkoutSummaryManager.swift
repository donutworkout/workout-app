//
//  WorkoutSummaryManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 21/11/25.
//

import Foundation
import HealthKit

struct DaySummary {
    var totalDuration: TimeInterval = 0
    var activeCalories: Double = 0
    var totalCalories: Double = 0
    var avgHeartRate: Double = 0
    var workoutCount: Int = 0
}

@MainActor
class WorkoutSummaryManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var weeklySummaries: [Int: DaySummary] = [:]
    @Published var isLoading: Bool = false
    

    private let allowedSourceBundleIDs: Set<String> = [
        "dawnhazed.WorkoutApp2",
        "dawnhazed.WorkoutApp2.watchkitapp"
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
    
    // MARK: - Per-day summary
    
    private func fetchDaySummary(for date: Date, category: MenuCategory) async -> DaySummary {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return DaySummary()
        }
        
        let workoutTypes: [HKWorkoutActivityType]
        switch category {
        case .cardio:
            workoutTypes = [
                .walking, .running, .cycling, .swimming,
                .basketball, .tennis, .badminton, .volleyball, .soccer
            ]
        case .strength:
            workoutTypes = [
                .traditionalStrengthTraining,
                .functionalStrengthTraining
            ]
        case .rest:
            return DaySummary()
        }
        
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
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: compoundPredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { [allowedSourceBundleIDs] _, samples, error in
                
                if samples == nil {
                    continuation.resume(returning: DaySummary())
                    return
                }
                
                let workouts = samples as! [HKWorkout]
                let filtered = workouts.filter { allowedSourceBundleIDs.contains($0.sourceRevision.source.bundleIdentifier) }
                
                if filtered.isEmpty {
                    continuation.resume(returning: DaySummary())
                    return
                }
                
                let startOfDayLocal = startOfDay
                let endOfDayLocal = endOfDay
                
                Task {
                    let summary = await self.computeSummary(for: filtered, startOfDay: startOfDayLocal, endOfDay: endOfDayLocal)
                    continuation.resume(returning: summary)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    private func computeSummary(for workouts: [HKWorkout], startOfDay: Date, endOfDay: Date) async -> DaySummary {
        var summary = DaySummary()
        var totalHeartRate = 0.0
        var heartRateCount = 0
        
        for workout in workouts {
            summary.totalDuration += workout.duration
            summary.workoutCount += 1
        }
        
        let active = await self.loadActiveEnergy(start: startOfDay, end: endOfDay)
        let basal = await self.loadBasalEnergy(start: startOfDay, end: endOfDay)
        
        summary.activeCalories = active
        summary.totalCalories = active + basal
        
        for workout in workouts {
            if let avgHR = await self.fetchAverageHeartRate(for: workout) {
                totalHeartRate += avgHR
                heartRateCount += 1
            }
        }
        
        if heartRateCount > 0 {
            summary.avgHeartRate = totalHeartRate / Double(heartRateCount)
        }
        
        return summary
    }
    
    // MARK: - Basal
    
    private func loadBasalEnergy(start: Date, end: Date) async -> Double {
        guard let type = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned) else {
            return 0
        }
        
        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, _ in
                let kcal = stats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: kcal)
            }
            
            healthStore.execute(query)
        }
    }

    // MARK: - Active
    
    private func loadActiveEnergy(start: Date, end: Date) async -> Double {
        guard let type = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return 0
        }
        
        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, _ in
                let kcal = stats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: kcal)
            }
            healthStore.execute(query)
        }
    }
    
    // MARK: - HR helper
    
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
            ) { _, statistics, _ in
                
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


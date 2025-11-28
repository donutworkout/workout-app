//
//  iPhoneHealthKitManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 21/11/25.
//

import Foundation
import HealthKit
import SwiftData

final class iPhoneHealthKitManager {
    static let shared = iPhoneHealthKitManager()
    private let healthStore = HKHealthStore()

        private init() {}
    
    func isAuthorized() -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        let status = healthStore.authorizationStatus(for: HKObjectType.workoutType())
        return status == .sharingAuthorized
    }


        // MARK: - Authorization
        func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
            guard HKHealthStore.isHealthDataAvailable() else {
                completion(false, nil)
                return
            }

            var toRead: Set<HKObjectType> = [
                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                HKObjectType.workoutType(),
                HKObjectType.categoryType(forIdentifier: .menstrualFlow)!
            ]

            let toShare: Set<HKSampleType> = [
                HKObjectType.workoutType(),
                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
            ]

            healthStore.requestAuthorization(toShare: toShare, read: toRead) { success, error in
                completion(success, error)
            }
        }

        // MARK: - Helper
        private func dayBounds(for date: Date) -> (start: Date, end: Date) {
            let cal = Calendar.current
            let start = cal.startOfDay(for: date)
            let end = cal.date(byAdding: .day, value: 1, to: start)!
            return (start, end)
        }

        // MARK: - Fetch workouts for a DailyMenu
        func fetchWorkouts(for menu: DailyMenu) async throws -> [HKWorkout] {
            let (start, end) = dayBounds(for: menu.date)

            let datePredicate = HKQuery.predicateForSamples(
                withStart: start,
                end: end,
                options: .strictStartDate
            )

            let brandPredicate = HKQuery.predicateForObjects(
                withMetadataKey: HKMetadataKeyWorkoutBrandName,
                allowedValues: ["HeyLoona!"]
            )

            let categoryPredicate = HKQuery.predicateForObjects(
                withMetadataKey: "WorkoutCategory",
                allowedValues: [menu.category.self]
            )

            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                datePredicate, brandPredicate, categoryPredicate
            ])

            return try await withCheckedThrowingContinuation { continuation in
                let query = HKSampleQuery(
                    sampleType: HKObjectType.workoutType(),
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit, sortDescriptors: nil
                ) { _, samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: samples as? [HKWorkout] ?? [])
                }

                self.healthStore.execute(query)
            }
        }

        // MARK: - Fetch heart rate samples
        func fetchHeartRates(for workout: HKWorkout) async throws -> [Double] {
            guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return [] }

            let predicate = HKQuery.predicateForSamples(
                withStart: workout.startDate,
                end: workout.endDate,
                options: .strictStartDate
            )

            return try await withCheckedThrowingContinuation { continuation in
                let query = HKSampleQuery(
                    sampleType: hrType,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: nil
                ) { _, samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    let bpm = (samples as? [HKQuantitySample])?.compactMap {
                        $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    } ?? []

                    continuation.resume(returning: bpm)
                }

                self.healthStore.execute(query)
            }
        }
    
    func getLastPeriodDate(completion: @escaping (Date?) -> Void) {
        guard let menstrualType = HKCategoryType.categoryType(forIdentifier: .menstrualFlow) else {
            completion(nil)
            return
        }
        
        let predicate = NSPredicate(format: "metadata.%K == YES", HKMetadataKeyMenstrualCycleStart)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: menstrualType,
            predicate: predicate,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { query, results, error in
            if let sample = results?.first {
                completion(sample.startDate)
            } else {
                completion(nil)
            }
        }
        
        healthStore.execute(query)
    }
        
    //    func syncCycleData(to userCycle: UserCycle) {
    //        getLastPeriodDate { date in
    //            if let lastPeriod = date {
    //                DispatchQueue.main.async {
    //                    userCycle.cycleStartDate = lastPeriod
    //                    print("✅ Synced cycle data: \(lastPeriod)")
    //                }
    //            }
    //        }
    //    }
}

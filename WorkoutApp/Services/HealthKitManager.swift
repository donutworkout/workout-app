//
//  HealthKitManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 20/10/25.
//

import Foundation
import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        struct HealthKitTypes {
            static let toRead: Set<HKObjectType> = [
                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                HKObjectType.workoutType(),
                
                HKObjectType.categoryType(forIdentifier: .menstrualFlow)!,
            ]
            
            static let toShare: Set<HKSampleType> = [
                HKObjectType.workoutType(),
                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
            ]
        }
        
        healthStore.requestAuthorization(toShare: HealthKitTypes.toShare, read: HealthKitTypes.toRead) { success, error in
            if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
                return
            }
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

//func typesToRead(for activity: HKWorkoutActivityType) -> Set<HKObjectType> {
//    var readTypes: Set<HKObjectType> = [
//        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
//        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
//        HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
//    ]
//
//    switch activity {
//    case .running, .walking:
//        readTypes.insert(
//            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
//        )
//        readTypes.insert(
//            HKQuantityType.quantityType(forIdentifier: .stepCount)!
//        )
//
//    case .cycling:
//        readTypes.insert(
//            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
//        )
//
//    case .swimming:
//        readTypes.insert(
//            HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!
//        )
//        readTypes.insert(
//            HKQuantityType.quantityType(forIdentifier: .swimmingStrokeCount)!
//        )
//
//    case .badminton, .basketball, .tennis, .volleyball, .soccer:
//        readTypes.insert(HKQuantityType.quantityType(forIdentifier: .vo2Max)!)
//
//    case .pilates, .coreTraining, .highIntensityIntervalTraining,
//        .traditionalStrengthTraining, .flexibility, .yoga, .martialArts:
//        readTypes.insert(
//            HKQuantityType.quantityType(
//                forIdentifier: .heartRateVariabilitySDNN
//            )!
//        )
//
//    default:
//        break
//    }
//
//    return readTypes
//}

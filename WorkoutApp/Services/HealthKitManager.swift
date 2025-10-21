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
                HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                HKObjectType.workoutType()
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

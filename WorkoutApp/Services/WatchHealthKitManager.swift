//
//  HealthKitManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 20/10/25.
//

import Foundation
import HealthKit

final class WatchHealthKitManager {
    static let shared = WatchHealthKitManager()
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
                HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
                HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
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
}

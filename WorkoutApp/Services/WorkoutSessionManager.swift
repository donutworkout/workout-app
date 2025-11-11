//
//  WorkoutSessionManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 17/10/25.
//

import Foundation
import HealthKit

enum WorkoutCommand: String {
    case start
    case started
    case stop
    case pause
    case resume
}

@Observable
class WorkoutSessionManager: NSObject {
    
    private var timer: Timer?
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    
    var heartRate: Double = 0.0
    var energyBurned: Double = 0.0
    var distance: Double = 0.0
    var isRunning: Bool = false
    var timeActive: Double = 0.0
    
    // MARK: - Start Workout
    
    func startWorkout(of type: HKWorkoutActivityType) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToShare: Set = [HKQuantityType.workoutType()]
        let typesToRead = typesToRead(for: type)
        
        healthStore.requestAuthorization(
            toShare: typesToShare,
            read: typesToRead
        ) { (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.beginWorkout(of: type)
                }
            } else {
                print(
                    "Authorization failed:",
                    error?.localizedDescription ?? "unknown"
                )
            }
        }
    }
    
    //MARK: - Begin Workout
    
    private func beginWorkout(of type: HKWorkoutActivityType) {
        let config = HKWorkoutConfiguration()
        config.activityType = type
        
        do {
            workoutSession = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: config
            )
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            
            guard let workoutBuilder = workoutBuilder else { return }
            
            workoutBuilder.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: config
            )
            workoutSession?.delegate = self
            workoutBuilder.delegate = self
            
            let startDate = Date()
            workoutSession?.startActivity(with: startDate)
            
            workoutBuilder.beginCollection(withStart: startDate) {
                success,
                error in
                DispatchQueue.main.async {
                    self.isRunning = true
                    self.startTimer()
                    print("Workout started (\(type.rawValue))")
                }
            }
        } catch {
            print(
                "Couldn't create workout session: \(error.localizedDescription)"
            )
        }
        
    }
    
    private func startTimer() {
        timer?.invalidate()
        timeActive = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.isRunning {
                self.timeActive += 1
            }
        }
    }
    
    func stopWorkout() {
//        print("workout session", workoutSession?.activityType.rawValue ?? "nil")
//        print("workout builder", workoutBuilder?.workoutSession?.activityType.rawValue ?? "nil")
        guard let session = workoutSession, let builder = workoutBuilder else {
            print("⚠️ No active workout to stop")
            return
        }
        print("🛑 Stopping workout session...")
        timer?.invalidate()
        isRunning = false
        session.end()
        builder.endCollection(withEnd: Date()) { _, _ in
            builder.finishWorkout { workout, error in
                DispatchQueue.main.async {
                    self.workoutSession = nil
                    self.workoutBuilder = nil
                    if let workout = workout {
                        print("✅ Workout finished cleanly: \(workout)")
                    } else if let error {
                        print("❌ Error finishing workout: \(error.localizedDescription)")
                    }
                    
                }
            }
            
        }
    }
    
    func pauseWorkout() {
        workoutSession?.pause()
    }

    func resumeWorkout() {
        workoutSession?.resume()
    }


}

// MARK: - HKWorkoutSessionDelegate

extension WorkoutSessionManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed with error: \(error)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        print("workout session generated")
    }
    
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            print("session running")
        case .ended:
            print("session ended")
        case .paused:
            print("session paused")
        default :
            break
        }
    }
}

extension WorkoutSessionManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            let statistics = workoutBuilder.statistics(for: quantityType)
            
            DispatchQueue.main.async {
                switch quantityType {
                case HKQuantityType.quantityType(forIdentifier: .heartRate):
                    let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                    self.heartRate = statistics?.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                    
                case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                    self.energyBurned = statistics?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                    
                case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
                    self.distance = statistics?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                    
                default:
                    break
                }
//                WatchConnectivityManager.shared.sendMessage([
//                        "cmd": "updateMetrics",
//                        "heartRate": self.heartRate,
//                        "energy": self.energyBurned,
//                        "distance": self.distance,
//                        "time": self.timeActive
//                    ])
            }
        }
    }
}

func typesToRead(for activity: HKWorkoutActivityType) -> Set<HKObjectType> {
    let readTypes: Set<HKObjectType> = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
        HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
        HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!,
        HKQuantityType.quantityType(forIdentifier: .swimmingStrokeCount)!
        
        
    ]
    
    return readTypes
}


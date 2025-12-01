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
    
    static let shared = WorkoutSessionManager()

    private var timer: Timer?
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    private var heartRateSamples: [Double] = []
    
    var heartRate: Double = 0.0
    var activeEnergy: Double = 0.0
    var basalEnergy: Double = 0.0
    var distance: Double = 0.0
    var isRunning: Bool = false
    var timeActive: Double = 0.0
    var isPaused: Bool = false
    
    var totalEnergy: Double {
        return activeEnergy + basalEnergy
    }
    
    private var lastMetricsSent: Date = .distantPast
    
    var averageHeartRate: Double {
        let sum = heartRateSamples.reduce(0, +)
        return heartRateSamples.isEmpty ? 0 : sum / Double(heartRateSamples.count)
    }

    private func sendMetricsToPhone() {
        let now = Date()
        guard now.timeIntervalSince(lastMetricsSent) >= 1 else { return }
        lastMetricsSent = now

        let connectivity = WatchConnectivityManager.shared
        connectivity.sendMetrics(
            heartRate: self.heartRate,
            energy: self.activeEnergy,
            distance: self.distance
        )
    }
    
    // MARK: - Start Workout
    
    func startWorkout(of type: HKWorkoutActivityType, isIndoor: Bool) {
        beginWorkout(of: type, isIndoor: isIndoor)
    }
    
    //MARK: - Begin Workout
    
    private func beginWorkout(of type: HKWorkoutActivityType, isIndoor: Bool) {
        let config = HKWorkoutConfiguration()
        config.activityType = type
        config.locationType = isIndoor ? .indoor : .outdoor
        
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
                    self.sendMetricsToPhone()
                    self.lastMetricsSent = .distantPast
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
        //timeActive = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard self.isRunning && !self.isPaused else { return }
            self.timeActive += 1
        }
    }
    
    func stopWorkout() {
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
                        let activeEnergyQuantity = builder.statistics(for: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!)?.sumQuantity()
                        let basalEnergyQuantity = builder.statistics(for: HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!)?.sumQuantity()
                        let activeKcals = activeEnergyQuantity?.doubleValue(for: .kilocalorie()) ?? 0
                        let basalKcals = basalEnergyQuantity?.doubleValue(for: .kilocalorie()) ?? 0
                        let totalKcals = activeKcals + basalKcals
                        
                        let summary: [String: Any] = [
                                "cmd": "workoutSummary",
                                "duration": workout.duration,
                                "activeEnergy": activeKcals,
                                "totalEnergy": totalKcals,
                                "distance": workout.totalDistance?.doubleValue(for: .meter()) ?? 0,
                                "avgHeartRate": self.averageHeartRate
                            ]
                            WatchConnectivityManager.shared.sendMessage(summary)
                        
                        self.workoutSession = nil
                        self.workoutBuilder = nil
                    } else if let error {
                        print("❌ Error finishing workout: \(error.localizedDescription)")
                    }
                    
                }
            }
            
        }
    }
    
    func pauseWorkout() {
        guard isRunning else { return }
        workoutSession?.pause()
        isPaused = true
        print("⌚️ Workout paused")
    }

    func resumeWorkout() {
        guard isPaused else { return }
        workoutSession?.resume()
        isPaused = false
        isRunning = true
        self.lastMetricsSent = .distantPast
        self.sendMetricsToPhone()
        print("⌚️ Workout resumed")
    }
    
    func resetWorkoutData() {
        // Stop & clear timer
        timer?.invalidate()
        timer = nil

        // Reset state and stats
        timeActive = 0
        heartRate = 0
        activeEnergy = 0
        basalEnergy = 0
        distance = 0
        heartRateSamples.removeAll()

        // ensure flags
        isRunning = false
        isPaused = false

        lastMetricsSent = .distantPast
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
                    let hrValue = statistics?.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
                    if let hr = hrValue, hr > 0 {
                        self.heartRate = hr
                        self.heartRateSamples.append(hr)
                    }
                    
                case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                    self.activeEnergy = statistics?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                    
                case HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned):
                    self.basalEnergy = statistics?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                    
                case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
                    self.distance = statistics?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                    
                default:
                    break
                }
                
                self.sendMetricsToPhone()

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


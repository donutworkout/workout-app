//
//  WorkoutSessionManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 17/10/25.
//

import Foundation
import HealthKit

final class WorkoutSessionManager: NSObject, ObservableObject {


    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?

    @Published var heartRate: Double = 0.0
    @Published var energyBurned: Double = 0.0
    @Published var distance: Double = 0.0
    @Published var isRunning: Bool = false
    @Published var timeActive: Double = 0.0
    
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
                    print("Workout started (\(type.rawValue))")
                }
            }
        } catch {
            print(
                "Couldn't create workout session: \(error.localizedDescription)"
            )
        }

    }

    func stopWorkout() {
        guard let session = workoutSession, let builder = workoutBuilder else {
            return
        }

        session.end()
        builder.endCollection(withEnd: Date()) { _, _ in
            builder.finishWorkout { workout, error in
                DispatchQueue.main.async {
                    self.isRunning = false
                    if let workout = workout {
                        print("Workout finished: \(workout)")
                    } else if let error {
                        print("Finished with error: \(error)")
                    }
                }
            }

        }
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
                    let unit = HKUnit(from: "count/min")
                    self.heartRate = statistics?.mostRecentQuantity()?.doubleValue(for: unit) ?? 0

                case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                    self.energyBurned = statistics?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0

                case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
                    self.distance = statistics?.sumQuantity()?.doubleValue(for: .meter()) ?? 0

                default:
                    break
                }
            }
        }
    }
}

func typesToRead(for activity: HKWorkoutActivityType) -> Set<HKObjectType> {
    var readTypes: Set<HKObjectType> = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
    ]

    switch activity {
    case .running, .walking:
        readTypes.insert(
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        )
        readTypes.insert(
            HKQuantityType.quantityType(forIdentifier: .stepCount)!
        )

    case .cycling:
        readTypes.insert(
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
        )

    case .swimming:
        readTypes.insert(
            HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!
        )
        readTypes.insert(
            HKQuantityType.quantityType(forIdentifier: .swimmingStrokeCount)!
        )

    case .badminton, .basketball, .tennis, .volleyball, .soccer:
        readTypes.insert(HKQuantityType.quantityType(forIdentifier: .vo2Max)!)

    case .pilates, .coreTraining, .highIntensityIntervalTraining,
        .traditionalStrengthTraining, .flexibility, .yoga, .martialArts:
        readTypes.insert(
            HKQuantityType.quantityType(
                forIdentifier: .heartRateVariabilitySDNN
            )!
        )

    default:
        break
    }

    return readTypes
}


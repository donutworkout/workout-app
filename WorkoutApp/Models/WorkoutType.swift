//
//  WorkoutType.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 17/10/25.
//

import HealthKit

struct WorkoutType: Hashable {
    let type: HKWorkoutActivityType
    let id: UUID
    let name: String
    
}

let workoutTypes: [WorkoutType] = [
    .init(type: .running, id: UUID(), name: "Running"),
    .init(type: .walking, id: UUID(), name: "Walking"),
    .init(type: .swimming, id: UUID(), name: "Swimming"),
    .init(type: .cycling, id: UUID(), name: "Cycling"),
    .init(type: .badminton, id: UUID(), name: "Badminton"),
    .init(type: .basketball, id: UUID(), name: "Basketball"),
    .init(type: .tennis, id: UUID(), name: "Tennis"),
    .init(type: .volleyball, id: UUID(), name: "Volleyball"),
    .init(type: .soccer, id: UUID(), name: "Soccer"),
    .init(type: .pilates, id: UUID(), name: "Pilates"),
    .init(type: .coreTraining, id: UUID(), name: "Core Training"),
    .init(type: .highIntensityIntervalTraining, id: UUID(), name: "HIIT"),
    .init(type: .traditionalStrengthTraining, id: UUID(), name: "Traditional Strength Training"),
    .init(type: .functionalStrengthTraining, id: UUID(), name: "Functional Strength Training"),
    .init(type: .martialArts, id: UUID(), name: "Martial Arts"),
    .init(type: .yoga, id: UUID(), name: "Yoga")
    ]

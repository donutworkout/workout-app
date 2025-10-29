//
//  Exercise.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 28/10/25.
//

import Foundation
import SwiftData

enum BodyPart: String, Codable, CaseIterable {
    case core
    case upper
    case lower
    case fullBody
    case back
    case glutes
    case shoulders
}

enum ExerciseType: String, Codable, CaseIterable {
    case mobility
    case stability
    case stretch
    case strength
    case hold
    case lightStrength
    case compound
    case dynamic
    case endurance
    case power
    case isolation
    case control
    case isometric
}

@Model
class Exercise: Identifiable {
    var id: UUID = UUID()
    var name: String
    var exerciseType: ExerciseType
    var bodyPart: BodyPart
    var sets: Int?
    var reps: Int?
    var time: Int? // pick one, rest/time
    var level: WorkoutLevel
    var phase: MenstrualPhase
    var imageName: String
    
    init(id: UUID, name: String, exerciseType: ExerciseType, bodyPart: BodyPart, sets: Int, reps: Int, time: Int, level: WorkoutLevel, phase: MenstrualPhase, imageName: String) {
        self.id = id
        self.name = name
        self.exerciseType = exerciseType
        self.bodyPart = bodyPart
        self.sets = sets
        self.reps = reps
        self.time = time
        self.level = level
        self.phase = phase
        self.imageName = imageName
    }
}

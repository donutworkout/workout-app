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
class Exercise{
    var id: UUID = UUID()
    var name: String = ""
    var exerciseType: ExerciseType = ExerciseType.mobility
    var bodyPart: BodyPart = BodyPart.fullBody
    var sets: Int?
    var reps: Int?
    var time: Int? // pick one, rest/time
    var level: WorkoutLevel = WorkoutLevel.beginner
    var phase: MenstrualPhase = MenstrualPhase.menstruation
    var imageName: String?
    
    init(
        
        id: UUID = UUID(),
        name: String,
        exerciseType: ExerciseType,
        bodyPart: BodyPart,
        sets: Int? = nil,
        reps: Int? = nil,
        time: Int? = nil,
        level: WorkoutLevel,
        phase: MenstrualPhase,
        imageName: String? = nil) {
            
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

// Add this inside the Exercise class in Exercise.swift

extension Exercise {
    var displayDetails: String {
        // You can customize this, but here's a good start
        if let sets = sets, let reps = reps {
            return "\(sets) sets x \(reps) reps"
        } else if let time = time {
            return "\(time) seconds"
        } else if let sets = sets {
            return "\(sets) sets"
        } else if let reps = reps {
            return "\(reps) reps"
        } else {
            return "No details"
        }
    }
}

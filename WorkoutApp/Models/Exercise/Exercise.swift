//
//  Exercise.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 28/10/25.
//

import Foundation
import SwiftData

enum BodyPart: String, Codable, CaseIterable {
    case fullBody
    case upperPush
    case upperPull
}

@Model
class Exercise{
    var id: UUID = UUID()
    var name: String = ""
    var bodyPart: [BodyPart] = []
    var sets: Int?
    var reps: Int?
    var time: Int? // pick one, rest/time
    var imageName: String?
    
    init(
        
        id: UUID = UUID(),
        name: String,
        bodyPart: [BodyPart],
        sets: Int? = nil,
        reps: Int? = nil,
        time: Int? = nil,
        imageName: String? = nil) {
            
        self.id = id
        self.name = name
        self.bodyPart = bodyPart
        self.sets = sets
        self.reps = reps
        self.time = time
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

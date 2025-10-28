//
//  Exercise.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 28/10/25.
//

import Foundation
import SwiftData

struct Exercise: Identifiable {
    var id: UUID = UUID()
    var name: String
    var sets: Int
    var reps: Int = 30
    var imageName: String
    
    init(id: UUID, name: String, sets: Int, reps: Int, imageName: String) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.imageName = imageName
    }
}

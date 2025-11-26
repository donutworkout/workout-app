//
//  WorkoutSessionSummary.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 24/11/25.
//

import Foundation
import SwiftData

@Model
class WorkoutSessionSummary {
    @Attribute(.unique) var id: UUID
    var workoutDate: Date
    var duration: TimeInterval
    var activeEnergy: Double
    var totalEnergy: Double
    var avgHeartRate: Double
    var distance: Double
    
    init(
        id: UUID = UUID(),
        workoutDate: Date,
        duration: TimeInterval,
        activeEnergy: Double,
        totalEnergy: Double,
        avgHeartRate: Double,
        distance: Double
    ) {
        self.id = id
        self.workoutDate = workoutDate
        self.duration = duration
        self.activeEnergy = activeEnergy
        self.totalEnergy = totalEnergy
        self.avgHeartRate = avgHeartRate
        self.distance = distance
    }
}

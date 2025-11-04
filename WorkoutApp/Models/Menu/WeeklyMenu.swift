//
//  WeeklyMenu.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 28/10/25.
//

import Foundation
import SwiftData

@Model
class WeeklyMenu: Identifiable {
  
    var id: UUID = UUID()
    var createdAt: Date
    var weekStartDate: Date
            
    @Relationship(deleteRule: .cascade) var workoutDays: [DailyMenu]
    //var generatedFor:
    var completedDays: Set<Int>
    
    init(
        createdAt: Date,
        weekStartDate: Date,
        workoutDays: [DailyMenu],
        completedDays: Set<Int> = []
    ) {
        self.createdAt = createdAt
        self.weekStartDate = weekStartDate
        self.workoutDays = workoutDays
        self.completedDays = completedDays
  }
}


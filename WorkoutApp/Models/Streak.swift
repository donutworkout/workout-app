//
//  Streak.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 24/11/25.
//

import Foundation
import SwiftData

@Model
class Streak {
    var lastWorkoutDate: Date
    var currentStreak: Int
    var longestStreak: Int
    var workoutsThisMonth: Int        // ✅ Track workouts in current month
    var lastMonthRecorded: Int        // ✅ Track which month we're counting
    var monthlyWorkoutGoal: Int
    
    init(
        lastWorkoutDate: Date = Date(),
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        workoutsThisMonth: Int = 0,
        lastMonthRecorded: Int = Calendar.current.component(.month, from: Date()),
        monthlyWorkoutGoal: Int = 0
    ) {
        self.lastWorkoutDate = lastWorkoutDate
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.workoutsThisMonth = workoutsThisMonth
        self.lastMonthRecorded = lastMonthRecorded
        self.monthlyWorkoutGoal = monthlyWorkoutGoal
    }
}

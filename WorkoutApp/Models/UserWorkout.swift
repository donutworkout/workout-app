//
//  UserWorkout.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 16/10/25.
//

import Foundation
import SwiftData

enum WorkoutGoal: String, CaseIterable {
  case buildMuscle = "Build Muscle"
  case loseWeight = "Lose Weight"
  case keepFit = "Keep Fit"
}

enum WorkoutLevel: String, CaseIterable {
  case beginner = "Beginner"
  case intermediate = "Intermediate"
  case advanced = "Advanced"
}

enum WorkoutDayPreference: String, CaseIterable {
  case monday = "Monday"
  case tuesday = "Tuesday"
  case wednesday = "Wednesday"
  case thursday = "Thursday"
  case friday = "Friday"
  case saturday = "Saturday"
  case sunday = "Sunday"
}

@Model
class UserWorkout: Identifiable {
  
  var id: UUID = UUID()
  var goal: WorkoutGoal
  var level: WorkoutLevel
  var free_days: [WorkoutDayPreference]
  
  @Relationship(deleteRule: .nullify, inverse: \UserProfile.id)
  var user: UserProfile?
  
  init(goal: WorkoutGoal, level: WorkoutLevel, free_days: [WorkoutDayPreference] ) {
    self.goal = goal
    self.level = level
    self.free_days = free_days
  }
}

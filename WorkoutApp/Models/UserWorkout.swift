//
//  UserWorkout.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 16/10/25.
//

import Foundation
import SwiftData

enum WorkoutGoal: String, Codable, CaseIterable {
  case buildMuscle = "Build Muscle"
  case loseWeight = "Lose Weight"
  case keepFit = "Keep Fit"
}

enum WorkoutLevel: String, Codable, CaseIterable {
  case beginner = "Beginner"
  case intermediate = "Intermediate"
  case advanced = "Advanced"
}

enum WorkoutDayPreference: String, Codable, CaseIterable {
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
  var workoutTimesAWeek: Int // berapa kali olahraga dalam seminggu
  var workoutDuration: Int
  var workoutRPE: Int
  var workoutExperience: Int // sudah berapa lama berolahraga
  var level: WorkoutLevel
  var freeDays: [WorkoutDayPreference]
  
  @Relationship(deleteRule: .nullify)
  var user: UserProfile?
  
  init(goal: WorkoutGoal, workoutTimesAWeek: Int, workoutDuration: Int, workoutRPE: Int, workoutExperience: Int, level: WorkoutLevel, freeDays: [WorkoutDayPreference] ) {
    self.goal = goal
    self.workoutTimesAWeek = workoutTimesAWeek
    self.workoutDuration = workoutDuration
    self.workoutRPE = workoutRPE
    self.workoutExperience = workoutExperience
    self.level = level
    self.freeDays = freeDays
  }
}

//
//  UserWorkout.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 16/10/25.
//

import Foundation
import SwiftData

enum WorkoutMotivation: String, Codable, CaseIterable {
    case buildMuscle
    case loseWeight
    case keepFit
}

enum WorkoutLevel: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced
}

enum WorkoutDayPreference: String, Codable, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    case flexible
}

/* 4/6 page */
enum WorkoutTimesAWeek: String, Codable, CaseIterable {
    case twoToThreeTimes
    case fourToFiveTimes
    case everyday
}

enum WorkoutDuration: String, Codable, CaseIterable {
    case underThirtyMinutes
    case thirtyToSixtyMinutes
    case aboveSixtyMinutes
}

enum WorkoutIntensity: String, Codable, CaseIterable {
    case light
    case moderate
    case hard
    case superIntense
}

enum WorkoutExperience: String, Codable, CaseIterable {
    case underOneMonth
    case oneToThreeMonths
    case fourToSixMonths
    case moreThanSixMonths
}

@Model
class UserWorkout: Identifiable {
  
    var id: UUID = UUID()
    var workoutMotivation: WorkoutMotivation
    var workoutTimesAWeek: WorkoutTimesAWeek // berapa kali olahraga dalam seminggu
    var workoutDuration: WorkoutDuration
    var workoutIntensity: WorkoutIntensity
    var workoutExperience: WorkoutExperience // sudah berapa lama berolahraga
    var workoutLevel: WorkoutLevel
    var workoutDaysPreference: [WorkoutDayPreference]
  
    @Relationship(deleteRule: .nullify)
    var user: UserProfile?
      
    init(
    workoutMotivation: WorkoutMotivation,
    workoutTimesAWeek: WorkoutTimesAWeek, // berapa kali olahraga dalam seminggu
    workoutDuration: WorkoutDuration,
    workoutIntensity: WorkoutIntensity,
    workoutExperience: WorkoutExperience, // sudah berapa lama berolahraga
    workoutLevel: WorkoutLevel,
    workoutDaysPreference: [WorkoutDayPreference], ) {
        self.workoutMotivation = workoutMotivation
        self.workoutTimesAWeek = workoutTimesAWeek
        self.workoutDuration = workoutDuration
        self.workoutIntensity = workoutIntensity
        self.workoutExperience = workoutExperience
        self.workoutLevel = workoutLevel
        self.workoutDaysPreference = workoutDaysPreference
    }
}

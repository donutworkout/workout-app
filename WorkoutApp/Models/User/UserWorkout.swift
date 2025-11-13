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
    
    var displayName: String {
        switch self {
        case .buildMuscle: return "Build Muscle"
        case .loseWeight: return "Lose Weight"
        case .keepFit: return "Keep Fit"
        }
    }
}

enum WorkoutLevel: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced
    
    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
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
    
    var displayName: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        case .flexible: return "Flexible"
        }
    }
}

/* 4/6 page */
enum WorkoutTimesAWeek: String, Codable, CaseIterable {
    case twoToThreeTimes
    case fourToFiveTimes
    case everyday
    
    var displayName: String {
        switch self {
        case .twoToThreeTimes: return "2-3x"
        case .fourToFiveTimes: return "4-5x"
        case .everyday: return "Everyday"
        }
    }
}

enum WorkoutDuration: String, Codable, CaseIterable {
    case underThirtyMinutes
    case thirtyToSixtyMinutes
    case aboveSixtyMinutes
    
    var displayName: String {
        switch self {
        case .underThirtyMinutes: return "< 30 min"
        case .thirtyToSixtyMinutes: return "30-60 min"
        case .aboveSixtyMinutes: return "> 60 min"
        }
    }
}

enum WorkoutIntensity: String, Codable, CaseIterable {
    case light
    case moderate
    case hard
    case superIntense
    
    var displayName: String {
        switch self {
        case .light: return "Light (you can still chat easily)"
        case .moderate: return "Moderate (a bit sweaty)"
        case .hard: return "Hard (sweating a lot, can't really talk)"
        case .superIntense: return "Super intense (pushing to your max)"
        }
    }
}

enum WorkoutExperience: String, Codable, CaseIterable {
    case underOneMonth
    case oneToThreeMonths
    case fourToSixMonths
    case moreThanSixMonths
    
    var displayName: String {
        switch self {
        case .underOneMonth: return "Newbie (<1 month)"
        case .oneToThreeMonths: return "1-3 months"
        case .fourToSixMonths: return "4-6 months"
        case .moreThanSixMonths: return "> 6 months"
        }
    }
}

@Model
class UserWorkout: Identifiable {
  
    var id: UUID = UUID()
    var workoutMotivation: WorkoutMotivation? = nil
    var workoutTimesAWeek: WorkoutTimesAWeek? = nil // berapa kali olahraga dalam seminggu
    var workoutDuration: WorkoutDuration? = nil
    var workoutIntensity: WorkoutIntensity? = nil
    var workoutExperience: WorkoutExperience? = nil // sudah berapa lama berolahraga
    var workoutLevel: WorkoutLevel = WorkoutLevel.beginner
    var workoutDaysPreference: [WorkoutDayPreference] = []
    var createdAt: Date = Date()
    
    @Relationship(deleteRule: .nullify)
    var user: UserProfile?
      
    init(
    workoutMotivation: WorkoutMotivation,
    workoutTimesAWeek: WorkoutTimesAWeek, // berapa kali olahraga dalam seminggu
    workoutDuration: WorkoutDuration,
    workoutIntensity: WorkoutIntensity,
    workoutExperience: WorkoutExperience, // sudah berapa lama berolahraga
    workoutLevel: WorkoutLevel,
    workoutDaysPreference: [WorkoutDayPreference],
    createdAt: Date = .now ) {
        self.workoutMotivation = workoutMotivation
        self.workoutTimesAWeek = workoutTimesAWeek
        self.workoutDuration = workoutDuration
        self.workoutIntensity = workoutIntensity
        self.workoutExperience = workoutExperience
        self.workoutLevel = workoutLevel
        self.workoutDaysPreference = workoutDaysPreference
        self.createdAt = createdAt
    }
}

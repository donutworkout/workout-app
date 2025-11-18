//
//  DailyMenu.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 28/10/25.
//

import Foundation
import SwiftData

enum MenuCategory: String, CaseIterable, Codable {
    case cardio
    case strength
    case rest
}

enum CardioOptions: String, CaseIterable, Codable {
    case outdoorWalk
    case indoorWalk
    case cycling
    case swimming
    case badminton
    case basketball
    case volleyball
    case tennis
    case padel
    case soccer
    
    var displayName: String {
        switch self {
        case .outdoorWalk: return "Outdoor Walk"
        case .indoorWalk: return "Indoor Walk"
        default : return self.rawValue.capitalized
        }
    }
}

enum StrengthType: String, CaseIterable, Codable {
    case bodyWeight
    case gym
    
    var displayName: String {
        switch self {
        case .bodyWeight: return "Body Weight"
        case .gym: return "Gym"
        }
    }
}

enum RestActivities: String, CaseIterable, Codable {
    case stretching
    case yoga
    case deepBreathing
    case meditation
} //testing

@Model
class DailyMenu: Identifiable {
    var id: UUID = UUID()
    var dayNumber: Int = 1
    var dayName: String = ""
    var date: Date = Date()
    
    var category: MenuCategory = MenuCategory.rest
    var cardioExercisesOption: [CardioOptions]?
    
    var strengthType: StrengthType?
    
    @Relationship(deleteRule: .cascade, inverse: \Exercise.dailyMenu)
    var strengthExercises: [Exercise]?

    var intensity: String?
    var estimatedDuration: Int?
    
    var restActivities: [RestActivities]?
    
    var isMenuComplete: Bool = false
    
    // for cardio
    var vigorousDuration: Int?
    var moderateDuration: Int?
    var targetHeartRate: Int?
    
    var isStrength: Bool { category == .strength }
    var isCardio: Bool { category == .cardio }
    var isRest: Bool { category == .rest }
      
    init(
        dayNumber: Int,
        dayName: String,
        date: Date,
        category: MenuCategory,
        cardioExercisesOption: [CardioOptions]? = nil,
        strengthExercises: [Exercise]? = nil,
        restActivities: [RestActivities]? = nil,
        intensity: String? = nil, // New
        estimatedDuration: Int? = nil, // New
        isMenuComplete: Bool = false,
        vigorousDuration: Int? = nil,
        moderateDuration: Int? = nil,
        targetHeartRate: Int? = nil
    ){
            self.dayNumber = dayNumber
            self.dayName = dayName
            self.date = date
            self.category = category
            self.cardioExercisesOption = cardioExercisesOption
            self.strengthExercises = strengthExercises
            self.restActivities = restActivities
            self.intensity = intensity // New
            self.estimatedDuration = estimatedDuration // New
            self.isMenuComplete = isMenuComplete
            self.vigorousDuration = vigorousDuration
            self.moderateDuration = moderateDuration
            self.targetHeartRate = targetHeartRate
    }
    
    static func cardioDay(dayNumber: Int, dayName: String, date: Date, cardioExercisesOption: [CardioOptions]? = nil, isMenuComplete: Bool = false, intensity: String, estimatedDuration: Int) -> DailyMenu {
        return DailyMenu(
            dayNumber: dayNumber,
            dayName: dayName,
            date: date,
            category: .cardio,
            cardioExercisesOption: cardioExercisesOption,
            intensity: "Low",
            estimatedDuration: estimatedDuration,
            isMenuComplete: isMenuComplete,
            
            )
    }
    
    static func strengthDay(dayNumber: Int, dayName: String, date: Date, strengthType: StrengthType, strengthExercises: [Exercise]? = nil, isMenuComplete: Bool = false, intensity: String, estimatedDuration: Int) -> DailyMenu {
        return DailyMenu(
            dayNumber: dayNumber,
            dayName: dayName,
            date: date,
            category: .strength,
            strengthExercises: strengthExercises,
            intensity: "Moderate",
            estimatedDuration: estimatedDuration,
            isMenuComplete: isMenuComplete
            )
    }
    
    static func restDay(dayNumber: Int, dayName: String, date: Date, restActivities: [RestActivities]? = nil) -> DailyMenu {
        return DailyMenu(
            dayNumber: dayNumber,
            dayName: dayName,
            date: date,
            category: .rest,
            restActivities: restActivities,
            intensity: "None",
            estimatedDuration: 15,
            isMenuComplete: false
        )
    }
}

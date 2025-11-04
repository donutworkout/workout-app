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
    var dayNumber: Int //1-7
    var dayName: String
    var date: Date?
    
    var category: MenuCategory
    var cardioExercisesOption: [CardioOptions]?
    
    var strengthType: StrengthType?
    //var strengthExercises: [Exercise]?
    @Relationship(deleteRule: .cascade) var strengthExercises: [Exercise]?

    var intensity: String?
    var estimatedDuration: Int?
    
    var restActivities: [RestActivities]?
    
    var isMenuComplete: Bool
    
    var isStrength: Bool { category == .strength }
    var isCardio: Bool { category == .cardio }
    var isRest: Bool { category == .rest }
      
    init(
        dayNumber: Int,
        dayName: String,
        date: Date? = nil,
        category: MenuCategory,
        cardioExercisesOption: [CardioOptions]? = nil,
        strengthExercises: [Exercise]? = nil,
        restActivities: [RestActivities]? = nil,
        intensity: String? = nil, // New
        estimatedDuration: Int? = nil, // New
        isMenuComplete: Bool = false
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
    }
    
    static func cardioDay(dayNumber: Int, dayName: String, date: Date? = nil, cardioExercisesOption: [CardioOptions]? = nil, isMenuComplete: Bool = false) -> DailyMenu {
        return DailyMenu(
            dayNumber: dayNumber,
            dayName: dayName,
            date: date,
            category: .cardio,
            cardioExercisesOption: cardioExercisesOption,
            intensity: "Low",
            estimatedDuration: 30,
            isMenuComplete: isMenuComplete
            )
    }
    
    static func strengthDay(dayNumber: Int, dayName: String, date: Date? = nil, strengthType: StrengthType, strengthExercises: [Exercise]? = nil, isMenuComplete: Bool = false) -> DailyMenu {
        return DailyMenu(
            dayNumber: dayNumber,
            dayName: dayName,
            date: date,
            category: .strength,
            strengthExercises: strengthExercises,
            intensity: "Moderate",
            estimatedDuration: 45,
            isMenuComplete: isMenuComplete
            )
    }
    
    static func restDay(dayNumber: Int, dayName: String, restActivities: [RestActivities]? = nil) -> DailyMenu {
        return DailyMenu(
            dayNumber: dayNumber,
            dayName: dayName,
            category: .rest,
            restActivities: restActivities,
            intensity: "None",
            estimatedDuration: 15,
            isMenuComplete: false
        )
    }
}

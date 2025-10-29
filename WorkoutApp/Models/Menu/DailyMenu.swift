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
}

enum StrengthType: String, CaseIterable, Codable {
    case bodyWeight
    case gym
}

@Model
class DailyMenu: Identifiable {
    var id: UUID = UUID()
    var dayNumber: Int //1-7
    var dayName: String
    var date: Date?
    
    var category: MenuCategory
    var cardioExercisesOption: [CardioOptions]?
    var strengthExercises: [StrengthType]?
    //var restActivities: [RestActivity]?
    
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
        strengthExercises: [StrengthType]? = nil,
        isMenuComplete: Bool,
        isStrength: Bool,
        isCardio: Bool,
        isRest: Bool) {
            self.dayNumber = dayNumber
            self.dayName = dayName
            self.date = date
            self.category = category
            self.cardioExercisesOption = cardioExercisesOption
            self.strengthExercises = strengthExercises
            self.isMenuComplete = isMenuComplete
    }
}

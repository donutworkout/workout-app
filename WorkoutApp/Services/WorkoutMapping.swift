//
//  WorkoutMapping.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 30/10/25.
//

import HealthKit

func mapActivityToHKType(_ activity: String) -> HKWorkoutActivityType {
    switch activity {
    case "Outdoor Walk", "Indoor Walk": return .walking
    case "Cycling": return .cycling
    case "Swimming": return .swimming
    case "Badminton": return .badminton
    case "Basketball": return .basketball
    case "Volleyball": return .volleyball
    case "Tennis", "Padel": return .tennis
    case "Soccer": return .soccer
    case "Bodyweight": return .functionalStrengthTraining
    case "Gym": return .traditionalStrengthTraining
    default: return .other
    }
}

extension HKWorkoutActivityType {
    var displayName: String {
        switch self {
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        case .swimming: return "Swimming"
        case .badminton: return "Badminton"
        case .basketball: return "Basketball"
        case .volleyball: return "Volleyball"
        case .tennis: return "Tennis"
        case .soccer: return "Soccer"
        case .functionalStrengthTraining: return "Bodyweight"
        case .traditionalStrengthTraining: return "Gym"
        default: return "Workout"
        }
    }
    
    var category: String {
            switch self {
            case .running, .cycling, .walking, .swimming, .badminton, .basketball, .tennis, .volleyball, .soccer:
                return "Cardio"
            case .traditionalStrengthTraining, .functionalStrengthTraining:
                return "Strength"
            default:
                return "Workout"
            }
        }
}



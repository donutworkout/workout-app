//
//  WorkoutMapping.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 30/10/25.
//

import HealthKit

func mapActivityToHKType(_ activity: String) -> (type: HKWorkoutActivityType, isIndoor: Bool) {
    let name = activity.lowercased()
    
    if name.contains("walk") {
        return (.walking, name.contains("indoor"))
    }
    if name.contains("run") {
        return (.running, name.contains("indoor"))
    }
    if name.contains("cycling") {
        return (.cycling, false)
    }
    if name.contains("swimming") {
        return (.swimming, true)
    }
    if name.contains("badminton") {
        return (.badminton, true)
    }
    if name.contains("basketball") {
        return (.basketball, false)
    }
    if name.contains("volleyball") {
        return (.volleyball, false)
    }
    if name.contains("tennis") {
        return (.tennis, false)
    }
    if name.contains("soccer") {
        return (.soccer, false)
    }
    if name.contains("bodyweight") {
        return (.functionalStrengthTraining, true)
    }
    if name.contains("gym") {
        return (.traditionalStrengthTraining, true)
    }
    return (.other, false)
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



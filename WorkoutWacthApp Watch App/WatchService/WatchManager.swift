//
//  WatchManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 29/10/25.
//
import Foundation
import HealthKit

@Observable
final class WorkoutManager  {
    enum Route {
        case notConnected
        case workoutList
        case activeWorkout(HKWorkoutActivityType)
    }
    
    var currentRoute: Route = .notConnected
    func startWorkout(_ type: HKWorkoutActivityType) {
        currentRoute = .activeWorkout(type)
    }
    
    func endWorkout() {
        currentRoute = .workoutList
    }
}

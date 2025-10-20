//
//  WatchWorkoutListView.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 18/10/25.
//

import SwiftUI
import HealthKit

struct WatchWorkoutListView: View {
    
    @StateObject var workoutManager = WorkoutSessionManager()
    
    let workouts: [(String, HKWorkoutActivityType)] = [
        ("Running", .running),
        ("Cycling", .cycling),
        ("Walking", .walking),
        ("Swimming", .swimming),
        ("Badminton", .badminton),
        ("Basketball", .basketball),
        ("Tennis", .tennis),
        ("Volleyball", .volleyball),
        ("Soccer", .soccer),
        ("Pilates", .pilates),
        ("Yoga", .yoga),
        ("Core Training", .coreTraining),
        ("High Intensity Interval Training", .highIntensityIntervalTraining),
        ("Traditional Strength Training", .traditionalStrengthTraining),
        ("Functional Strength Training", .functionalStrengthTraining),
        ("Martial Arts", .martialArts),
        
    ]
    var body: some View {
        VStack {
            if workoutManager.isRunning {
                VStack{
                    Text("💓 \(Int(workoutManager.heartRate)) bpm")
                    Text("🔥 \(Int(workoutManager.energyBurned)) kcal")
                    Text("📏 \(String(format: "%.1f", workoutManager.distance / 1000)) km")
                    Button("Stop Workout") {
                        workoutManager.stopWorkout()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            } else {
                List(workouts, id: \.0) { (name, type) in
                    Button(name) {
                        workoutManager.startWorkout(of: type)
                    }
                }
            }
        }
    }
}
               


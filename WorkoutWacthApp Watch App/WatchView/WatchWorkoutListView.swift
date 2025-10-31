//
//  WatchWorkoutListView.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 18/10/25.
//

import HealthKit
import SwiftUI

struct WatchWorkoutListView: View {

    @Environment var sessionManager: WorkoutSessionManager
    @Environment var connectivity: WatchConnectivityManager

    let cardioWorkouts: [(String, HKWorkoutActivityType)] = [
        ("Running", .running),
        ("Cycling", .cycling),
        ("Walking", .walking),
        ("Swimming", .swimming),
        ("Badminton", .badminton),
        ("Basketball", .basketball),
        ("Tennis", .tennis),
        ("Volleyball", .volleyball),
        ("Soccer", .soccer),
    ]

    let strengthWorkouts: [(String, HKWorkoutActivityType)] = [
//        ("Core Training", .coreTraining),
//        ("High Intensity Interval Training", .highIntensityIntervalTraining),
        ("Traditional Strength Training", .traditionalStrengthTraining),
        ("Functional Strength Training", .functionalStrengthTraining),

    ]
    
    let workoutType: HKWorkoutActivityType

    //    let workouts: [(String, HKWorkoutActivityType)] = [
    //        ("Running", .running),
    //        ("Cycling", .cycling),
    //        ("Walking", .walking),
    //        ("Swimming", .swimming),
    //        ("Badminton", .badminton),
    //        ("Basketball", .basketball),
    //        ("Tennis", .tennis),
    //        ("Volleyball", .volleyball),
    //        ("Soccer", .soccer),
    //        ("Pilates", .pilates),
    //        ("Yoga", .yoga),
    //        ("Core Training", .coreTraining),
    //        ("High Intensity Interval Training", .highIntensityIntervalTraining),
    //        ("Traditional Strength Training", .traditionalStrengthTraining),
    //        ("Functional Strength Training", .functionalStrengthTraining),
    //        ("Martial Arts", .martialArts),
    //
    //    ]
    
    var body: some View {
        VStack {
            Image(systemName: "figure.run")
                .font(.system(size: 50))
                .foregroundStyle(Color(.pink))
            Text("WorkoutName:\(workoutType.displayName)")
                .font(.largeTitle)
//            Button("Start Workout") {
//                self.connectivity.sendMessage(["startWorkout": true])
        
        }
//            NavigationStack {
//                List {
//                    if connectivity.todayCategory == .cardio {
//                        Section("Today: Cardio") {
//                            ForEach(cardioWorkouts, id: \.0) { workout in
//                                NavigationLink(destination: WatchActiveWorkoutView(sessionManager: _sessionManager, workoutType: workout.1, workoutName: workout.0)) {
//                                    Text(workout.0)
//                                }
//                            }
//                        }
//                    } else if connectivity.todayCategory == .strength {
//                        Section("Today: Strength") {
//                            ForEach(strengthWorkouts, id: \.0) { workout in
//                                NavigationLink(destination: WatchActiveWorkoutView(sessionManager: _sessionManager, workoutType: workout.1, workoutName: workout.0)) {
//                                    Text(workout.0)
//                                }
//                            }
//                        }
//                    }
//                }
//                .navigationTitle("Workouts")
//            }
        }
}

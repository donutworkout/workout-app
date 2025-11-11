//
//  WatchWorkoutListView.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 18/10/25.
//

import SwiftUI
import HealthKit

struct WatchWorkoutListView: View {
    
    @Environment var sessionManager: WorkoutSessionManager
    @Environment var connectivity: WatchConnectivityManager
    
    let workoutType: HKWorkoutActivityType
    
    // MARK: - Workout Data (contoh tetap statis dulu)
//    let workoutName = "Cardio"
//    let workoutIcon = "figure.run"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color("grayBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Spacer()
                    
                    Text(workoutType.category)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName:getWorkoutIcon(for: workoutType))
                        .font(.system(size: 50, weight: .regular))
                        .foregroundColor(Color("pinkTextPrimary"))
                    
                    Text(workoutType.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("pinkTextPrimary"))
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button(action: {
                    connectivity.sendMessage([
                        "cmd": WorkoutCommand.start.rawValue,
                        "workoutType": workoutType.rawValue
                    ])
                }) {
                    Text("START")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color("grayTextPrimary"))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
        }
    }
    
    private func getWorkoutIcon(for type: HKWorkoutActivityType) -> String {
            switch type {
            case .running: return "figure.run"
            case .cycling: return "figure.outdoor.cycle"
            case .walking: return "figure.walk"
            case .swimming: return "figure.pool.swim"
            case .basketball: return "figure.basketball"
            case .tennis: return "figure.tennis"
            case .badminton: return "figure.badminton"
            case .volleyball: return "figure.volleyball"
            case .soccer: return "figure.soccer"
            case .traditionalStrengthTraining: return "figure.strengthtraining.traditional"
            case .functionalStrengthTraining: return "figure.functional.training"
            default: return "figure.walk"
            }
        }
}
    
    // MARK: - Helper
    //    private var categoryName: String {
    //        switch connectivity.todayCategory {
    //        case .cardio:
    //            return "Cardio"
    //        case .strength:
    //            return "Strength"
    //        default:
    //            return "Workout"
    //        }
    //    }
    //
    //    private var categoryIcon: String {
    //        switch connectivity.todayCategory {
    //        case .cardio:
    //            return "figure.run"
    //        case .strength:
    //            return "figure.strengthtraining.traditional"
    //        default:
    //            return "figure.mixed.cardio"
    //        }
    //    }
    //
    //    private var currentWorkouts: [(String, HKWorkoutActivityType)] {
    //        switch connectivity.todayCategory {
    //        case .cardio:
    //            return cardioWorkouts
    //        case .strength:
    //            return strengthWorkouts
    //        default:
    //            return cardioWorkouts
    //        }
    //    }
    
    //#Preview {
    //    let mockSession = WorkoutSessionManager()
    //    let mockConnectivity = WatchConnectivityManager()
    //    mockConnectivity.todayCategory = .cardio
    //
    //    return WatchWorkoutListView()
    //        .environmentObject(mockSession)
    //        .environmentObject(mockConnectivity)
    //}
    
//    let cardioWorkouts: [(String, HKWorkoutActivityType)] = [

    // MARK: - Helper
//    private var categoryName: String {
//        switch connectivity.todayCategory {
//        case .cardio:
//            return "Cardio"
//        case .strength:
//            return "Strength"
//        default:
//            return "Workout"
//        }
//    }
//    
//    private var categoryIcon: String {
//        switch connectivity.todayCategory {
//        case .cardio:
//            return "figure.run"
//        case .strength:
//            return "figure.strengthtraining.traditional"
//        default:
//            return "figure.mixed.cardio"
//        }
//    }
//    
//    private var currentWorkouts: [(String, HKWorkoutActivityType)] {
//        switch connectivity.todayCategory {
//        case .cardio:
//            return cardioWorkouts
//        case .strength:
//            return strengthWorkouts
//        default:
//            return cardioWorkouts
//        }
//    }

//#Preview {
//    let mockSession = WorkoutSessionManager()
//    let mockConnectivity = WatchConnectivityManager()
//    mockConnectivity.todayCategory = .cardio
//    
//    return WatchWorkoutListView()
//        .environmentObject(mockSession)
//        .environmentObject(mockConnectivity)
//}
   
//    let cardioWorkouts: [(String, HKWorkoutActivityType)] = [
//        ("Running", .running),
//        ("Cycling", .cycling),
//        ("Walking", .walking),
//        ("Swimming", .swimming),
//        ("Badminton", .badminton),
//        ("Basketball", .basketball),
//        ("Tennis", .tennis),
//        ("Volleyball", .volleyball),
//        ("Soccer", .soccer),
//    ]
//    
//    let strengthWorkouts: [(String, HKWorkoutActivityType)] = [
//        //        ("Core Training", .coreTraining),
//        //        ("High Intensity Interval Training", .highIntensityIntervalTraining),
//        ("Traditional Strength Training", .traditionalStrengthTraining),
//        ("Functional Strength Training", .functionalStrengthTraining),
//        
//    ]
//    
//    let workoutType: HKWorkoutActivityType
//
//    var body: some View {
//        VStack {
//            Image(systemName: "figure.run")
//                .font(.system(size: 50))
//                .foregroundStyle(Color(.pink))
//            Text("WorkoutName:\(workoutType.displayName)")
//            Button("Start Workout") {
//                connectivity.sendMessage([
//                        "cmd": WorkoutCommand.start.rawValue,
//                        "workoutType": workoutType.rawValue
//                    ])
//            }
//        }
//    }

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
//    ]
//    
//    let strengthWorkouts: [(String, HKWorkoutActivityType)] = [
//        //        ("Core Training", .coreTraining),
//        //        ("High Intensity Interval Training", .highIntensityIntervalTraining),
//        ("Traditional Strength Training", .traditionalStrengthTraining),
//        ("Functional Strength Training", .functionalStrengthTraining),
//        
//    ]
//    
//    let workoutType: HKWorkoutActivityType
//    
//    var body: some View {
//        VStack {
//            Image(systemName: "figure.run")
//                .font(.system(size: 50))
//                .foregroundStyle(Color(.pink))
//            Text("WorkoutName:\(workoutType.displayName)")
//            Button("Start Workout") {
//                connectivity.sendMessage([
//                    "cmd": WorkoutCommand.start.rawValue,
//                    "workoutType": workoutType.rawValue
//                ])
//            }
//        }
//    }
//}
    
    
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


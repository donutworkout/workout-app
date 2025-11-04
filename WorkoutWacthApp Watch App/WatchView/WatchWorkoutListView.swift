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
    
    // MARK: - Workout Data (contoh tetap statis dulu)
    let workoutName = "Cardio"
    let workoutIcon = "figure.run"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Background
            Color("grayBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Content Area (Scrollable/Flexible)
                VStack(spacing: 16) {
                    Spacer()
                    
                    // MARK: - Workout Category
                    Text(workoutName)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                    
                    // MARK: - Icon
                    Image(systemName: workoutIcon)
                        .font(.system(size: 50, weight: .regular))
                        .foregroundColor(Color("pinkTextPrimary"))
                    
                    // MARK: - Workout Name
                    Text("Tennis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("pinkTextPrimary"))
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // MARK: - Fixed Bottom Button
                Button(action: {
                    
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

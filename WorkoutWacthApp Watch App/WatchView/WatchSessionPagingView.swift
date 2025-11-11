//
//  WatchSessionPagingView.swift
//  WorkoutWatchApp Watch App
//
//  Created by Valencia Melita Christy on 03/11/25.
//

import SwiftUI
import HealthKit

struct WatchSessionPagingView: View {
    @Environment(WorkoutSessionManager.self) private var sessionManager
    @Environment(WatchConnectivityManager.self) private var connectivity

    let workoutType: HKWorkoutActivityType
    let workoutName: String

    @State private var selectedTab: Tab = .metrics

    enum Tab {
        case metrics
        case controls
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Page 1: Dynamic Metrics
            Group {
                if isStrengthWorkout(workoutType) {
                    WatchWorkoutStrengthView()
                } else {
                    WatchWorkoutCardioView(workoutType: workoutType)
                }
            }
            .tag(Tab.metrics)

            // MARK: - Page 2: Controls
            WatchWorkoutControlsView()
                .tag(Tab.controls)
        }
        .tabViewStyle(.page)
        .onAppear {
            if !sessionManager.isRunning {
                sessionManager.startWorkout(of: workoutType)
                print("🏋️ Starting workout: \(workoutName)")
            }
        }
    }

    private func isStrengthWorkout(_ type: HKWorkoutActivityType) -> Bool {
        return type == .traditionalStrengthTraining || type == .functionalStrengthTraining
    }
}

#Preview {
    WatchSessionPagingView(
        workoutType: .traditionalStrengthTraining,
        workoutName: "Strength Training"
    )
    .environment(WorkoutSessionManager())
    .environment(WatchConnectivityManager())
}

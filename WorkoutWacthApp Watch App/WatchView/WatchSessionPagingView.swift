//
//  WatchSessionPagingView.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 03/11/25.
//

import SwiftUI
import HealthKit

struct WatchSessionPagingView: View {
    @Environment(WorkoutSessionManager.self) var sessionManager
    let workoutType: HKWorkoutActivityType
    let workoutName: String
    
    @State private var selected: Tab = .metrics
    
    enum Tab { case metrics, controls }

    var body: some View {
        TabView(selection: $selected) {
            WatchActiveWorkoutView(
                sessionManager: _sessionManager,
                workoutType: workoutType,
                workoutName: workoutName
            )
            .tag(Tab.metrics)

            WatchControlsView(sessionManager: _sessionManager)
                .tag(Tab.controls)
        }
        .tabViewStyle(.page)
    }
}



//
//  ContentView.swift
//  WorkoutWacthApp Watch App
//
//  Created by Nadaa Shafa Nadhifa on 14/10/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(WatchConnectivityManager.self) private var connectivity
    @Environment(WorkoutSessionManager.self) private var sessionManager

    var body: some View {
        if connectivity.isReachable && connectivity.todayCategory != nil {
            WatchWorkoutListView(sessionManager: _sessionManager, connectivity: _connectivity)
        } else {
            WatchNotConnectedView(connectivity: _connectivity)
        }
    }
}


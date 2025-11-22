//
//  WorkoutWacthAppApp.swift
//  WorkoutWacthApp Watch App
//
//  Created by Nadaa Shafa Nadhifa on 14/10/25.
//

import SwiftUI

@main
struct WorkoutWacthApp_Watch_AppApp: App {
    
    init() {
        WatchHealthKitManager.shared.requestAuthorization()
    }
    @State private var sessionManager = WorkoutSessionManager.shared
    @State private var connectivity = WatchConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sessionManager)
                .environment(connectivity)
        }
    }
}

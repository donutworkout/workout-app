//
//  WorkoutAppApp.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 14/10/25.
//

import SwiftUI
import SwiftData

@main
struct WorkoutAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            UserWorkout.self,
            UserCycle.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic  // enables CloudKit sync
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

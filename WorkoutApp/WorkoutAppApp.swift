//
//  WorkoutAppApp.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 14/10/25.
//

import SwiftUI
import SwiftData
import WatchConnectivity

@main
struct WorkoutAppApp: App {
    
    @StateObject private var router = Router()
    @StateObject private var surveyManager = SurveyManager(modelContext: WorkoutAppApp.modelContainer.mainContext)
    @State var connectivity = iPhoneConnectivityManager.shared
    
    
    static let modelContainer: ModelContainer = {
        do {
            let schema = Schema([
                UserProfile.self,
                UserWorkout.self,
                UserCycle.self,
                Exercise.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic // This enables CloudKit!
            )
            
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            container.mainContext.autosaveEnabled = true
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var iPhoneConnect = iPhoneConnectivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            RouterView()
                .environmentObject(router)
                .environmentObject(surveyManager)
                .environment(connectivity)
        }
        .modelContainer(WorkoutAppApp.modelContainer)
    }
}

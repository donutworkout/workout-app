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
    
    @StateObject private var router = Router()
    @StateObject private var surveyManager = SurveyManager(modelContext: WorkoutAppApp.modelContainer.mainContext)
    
    static let modelContainer: ModelContainer = {
        do {
            let schema = Schema([
                UserProfile.self,
                UserWorkout.self,
                UserCycle.self
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
    
    init() {
        HealthKitManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            SurveyView()
                .environmentObject(router)
                .environmentObject(surveyManager)
        }
        .modelContainer(WorkoutAppApp.modelContainer)
    }
}

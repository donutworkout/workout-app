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
    @StateObject var sessionManager = StrengthSessionManager.shared
    @State private var connectivity = iPhoneConnectivityManager.shared
    
    static let modelContainer: ModelContainer = {
        do {
            let schema = Schema([
                UserProfile.self,
                UserWorkout.self,
                UserCycle.self,
                Exercise.self,
                DailyMenu.self,
                Streak.self,
                WorkoutSessionSummary.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none // This enables CloudKit!
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
        checkFirstLaunchAndCleanup()
    }
    
    var body: some Scene {
        WindowGroup {
            RouterView()
                .environmentObject(router)
                .environmentObject(surveyManager)
                .environment(connectivity)
                .environmentObject(sessionManager)
                .environmentObject(router)
                .preferredColorScheme(.light)
        }
        .modelContainer(WorkoutAppApp.modelContainer)
    }
    
    private func checkFirstLaunchAndCleanup() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "HasLaunchedBefore")
        
        if !hasLaunchedBefore {
            print("🆕 First launch detected - setting up fresh data")
            
            let context = WorkoutAppApp.modelContainer.mainContext
            
            // Clear everything
            DummyExerciseProvider.shared.clearAllExercises(from: context)
            clearOldMenus(from: context)
            
            // Insert fresh exercises (will work because database is empty)
            Task {
                await DummyExerciseProvider.shared.insertDummyData(into: context)
            }
            
            // Mark as launched
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            print("✅ First launch setup complete")
        } else {
            print("✅ App has been launched before - skipping cleanup")
        }
    }
    
    private func clearOldMenus(from context: ModelContext) {
        do {
            try context.delete(model: DailyMenu.self)
            try context.save()
            print("✅ Cleared all old menus from database")
        } catch {
            print("❌ Failed to clear menus: \(error)")
        }
    }
}

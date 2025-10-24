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
  
    let modelContainer: ModelContainer
    
    init() {
        HealthKitManager.shared.requestAuthorization()
    }
    var sharedModelContainer: ModelContainer = {
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
      
        modelContainer = try ModelContainer(
          for: schema,
          configurations: [modelConfiguration]
        )
        
        modelContainer.mainContext.autosaveEnabled = true
        
      } catch {
        fatalError("Could not create ModelContainer: \(error)")
      }
    }
    
    var iPhoneConnect = iPhoneConnectivityManager.shared
      
    var body: some Scene {
        WindowGroup {
            SurveyView()
        }
        .modelContainer(modelContainer)
    }
}

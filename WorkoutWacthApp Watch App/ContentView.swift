//
//  ContentView.swift
//  WorkoutWacthApp Watch App
//
//  Created by Nadaa Shafa Nadhifa on 14/10/25.
//

import SwiftUI
import HealthKitUI

struct ContentView: View {
    @Environment(WatchConnectivityManager.self) private var connectivity
    @Environment(WorkoutSessionManager.self) private var sessionManager

    @State private var showCountdown = false
    @State private var countdownValue = 3
    @State private var workoutStarted = false
    
    var body: some View {
           Group {
               if !connectivity.isReachable {
                              WatchNotConnectedView(connectivity: _connectivity)

                          } else if let type = connectivity.selectedWorkoutType {
                              if showCountdown {
                                  
                              }
                              if sessionManager.isRunning {
                                  WatchSessionPagingView(
                                      sessionManager: _sessionManager,
                                      workoutType: type,
                                      workoutName: type.displayName
                                  )
                              } else {
                                  WatchWorkoutListView(
                                      sessionManager: _sessionManager,
                                      connectivity: _connectivity
                                  )
                              }

                          } else {
                              WatchNotConnectedView(connectivity: _connectivity)
                          }
           }
           .onChange(of: connectivity.shouldStartWorkout) { _, newValue in
               if newValue,
                  let type = connectivity.selectedWorkoutType {
                   sessionManager.startWorkout(of: type)
                   WKInterfaceDevice.current().play(.start) // ✅ Haptic feedback on start
               } else if !newValue {
                   sessionManager.stopWorkout()
                   WKInterfaceDevice.current().play(.stop) // ✅ Haptic feedback on stop
               }
           }
           .animation(.easeInOut, value: connectivity.selectedWorkoutType)
       }
}

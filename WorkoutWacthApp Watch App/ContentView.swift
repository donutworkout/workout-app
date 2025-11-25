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
    @State private var showDoneView = false

    
    var body: some View {
        Group {
            if showDoneView {
                WatchWorkoutDoneView(showDoneView: $showDoneView)
            } else if !connectivity.isReachable {
                WatchNotConnectedView(connectivity: _connectivity)
                
            } else if let type = connectivity.selectedWorkoutType {
                if showCountdown {
                    WatchCountdownView(count: countdownValue)
                        .onAppear {
                            withAnimation(.easeInOut) {
                                if countdownValue == 3 {
                                    startCountdown(for: type)
                                }
                            }
                        }
                } else if workoutStarted && sessionManager.isRunning {
                    WatchSessionPagingView(
                        workoutType: type,
                        workoutName: type.displayName
                    )
                } else {
                    StartView(
                        workoutType: type,
                        connectivity: _connectivity,
                        sessionManager: _sessionManager,
                    )
                }
                
            } else {
                WatchNotConnectedView(connectivity: _connectivity)
            }
        }
        .onChange(of: connectivity.shouldStartWorkout) { _, newValue in
            if newValue,
               let type = connectivity.selectedWorkoutType {
                showCountdown = true
                countdownValue = 3
                workoutStarted = false
            } else if !newValue && workoutStarted {
                print("stop workout!!")
                sessionManager.stopWorkout()
                WKInterfaceDevice.current().play(.stop)
                showDoneView = true
                workoutStarted = false
            }
        }
//        .onChange(of: showDoneView) { _, newValue in
//            if newValue {
//                    withAnimation(.easeInOut) {
//                        showDoneView = false
//                        connectivity.selectedWorkoutType = nil
//                        connectivity.shouldStartWorkout = false
//                        print("⌚ Auto-dismiss done view → back to menu")
//                    }
//            }
//        }
//        .animation(.easeInOut, value: connectivity.selectedWorkoutType)
//        .animation(.easeInOut, value: workoutStarted)
////        .onAppear {
//            print("appear stop")
//            sessionManager.stopWorkout()
//        }
    }
    
    private func startCountdown(for type: HKWorkoutActivityType) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            countdownValue -= 1
            WKInterfaceDevice.current().play(.click)
            
            if countdownValue == 0 {
                timer.invalidate()
                
                // Start workout
                sessionManager.startWorkout(of: type, isIndoor: connectivity.selectedIsIndoor)
                WKInterfaceDevice.current().play(.start)
                
                // Notify phone that watch has started
                connectivity.sendMessage([
                    "cmd": WorkoutCommand.started.rawValue
                ])
                print("run abis countdown")
                // Update state
                showCountdown = false
                workoutStarted = true
                print("connectivity.shouldStartWorkout\(connectivity.shouldStartWorkout)")
            }
        }
    }
}


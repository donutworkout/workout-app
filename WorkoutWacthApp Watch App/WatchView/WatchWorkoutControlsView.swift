//
//  WatchWorkoutControlsView.swift
//  WorkoutWatchApp Watch App
//
//  Created by Jennifer Evelyn on 04/11/25.
//

import SwiftUI
import HealthKit

struct WatchWorkoutControlsView: View {
    @Environment(WorkoutSessionManager.self) private var sessionManager
    @Environment(WatchConnectivityManager.self) private var connectivity

    @State private var isPaused: Bool = false

    var body: some View {
        VStack {
            // MARK: - Top Bar
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: getWorkoutIcon(for: connectivity.selectedWorkoutType ?? .walking))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("pinkTextPrimary"))
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 0)

            Spacer()   // Mengisi ruang atas–tengah
            Spacer()

            // MARK: - Buttons (Center block)
            VStack(spacing: 12) {
                PrimaryGlassButton(
                    title: isPaused ? "RESUME" : "PAUSE",
                    icon: isPaused ? "play.fill" : "pause.fill"
                ) {
                    if isPaused {
                        isPaused = false
                        sessionManager.resumeWorkout()
                        connectivity.sendMessage(["cmd": "resume"])
                    } else {
                        isPaused = true
                        sessionManager.pauseWorkout()
                        connectivity.sendMessage(["cmd": "pause"])
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 40)

                NeutralGlassButton(title: "STOP", icon: "stop.fill") {
                    sessionManager.stopWorkout()
                    connectivity.sendMessage([
                        "cmd": WorkoutCommand.stop.rawValue
                    ])
                    connectivity.shouldStartWorkout = false
                    WKInterfaceDevice.current().play(.stop)
                    print("🛑 Workout stopped from watch controls")
                }
                .frame(maxWidth: .infinity, minHeight: 40)
            }
            .padding(.horizontal, 12)

            Spacer()   // Tombol tetap proporsional ke bawah
        }
        .onChange(of: sessionManager.isPaused) { _, paused in
            isPaused = paused
        }
    }
    
    private func getWorkoutIcon(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: return "figure.run"
        case .cycling: return "figure.outdoor.cycle"
        case .walking: return "figure.walk"
        case .swimming: return "figure.pool.swim"
        case .basketball: return "figure.basketball"
        case .tennis: return "figure.tennis"
        case .badminton: return "figure.badminton"
        case .volleyball: return "figure.volleyball"
        case .soccer: return "figure.soccer"
        case .traditionalStrengthTraining: return "figure.strengthtraining.traditional"
        case .functionalStrengthTraining: return "figure.strengthtraining.functional"
        default: return "figure.walk"
        }
    }
}

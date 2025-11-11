//
//  WatchWorkoutControlsView.swift
//  WorkoutWatchApp Watch App
//
//  Created by Jennifer Evelyn on 04/11/25.
//

// page 1 yang start stop, page 2 nya di WatchWorkoutStatsView

import SwiftUI
import HealthKit

struct WatchWorkoutControlsView: View {
    @Environment(WorkoutSessionManager.self) private var sessionManager
    @Environment(WatchConnectivityManager.self) private var connectivity

    @State private var currentTime: String = ""
    @State private var isPaused: Bool = false
    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    var body: some View {

            // MARK: - Page 1: Controls
            VStack(spacing: 0) {
                // MARK: - Top Bar
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 36, height: 36)

                        //                        Image(systemName: getWorkoutIcon(for: connectivity.selectedWorkoutType ?? .walking))
                        Image(systemName: "figure.run")
                            .font(.system(size: 18))
                            .foregroundColor(Color("pinkTextPrimary"))
                    }

                    Spacer()

                    Text(currentTime)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .onReceive(clockTimer) { _ in updateTime() }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)

                Spacer()

                // MARK: - Control Buttons
                VStack(spacing: 12) {
                    PrimaryGlassButton(
                        title: isPaused ? "RESUME" : "PAUSE",
                        icon: isPaused ? "play.fill" : "pause.fill"
                    ) {
                        isPaused.toggle()
                        if sessionManager.isRunning {
                            // 🔸 Pause the session
                            sessionManager.pauseWorkout()
                            connectivity.sendMessage([
                                "cmd": WorkoutCommand.pause.rawValue
                            ])
                        } else {
                            // 🔸 Resume the session
                            sessionManager.resumeWorkout()
                            connectivity.sendMessage([
                                "cmd": WorkoutCommand.resume.rawValue
                            ])
                        }
                    }
                    .frame(height: 50)

                    NeutralGlassButton(title: "STOP", icon: "stop.fill") {
                        sessionManager.stopWorkout()
                        connectivity.sendMessage([
                            "cmd": WorkoutCommand.stop.rawValue
                        ])
                        connectivity.shouldStartWorkout = false
                        WKInterfaceDevice.current().play(.stop)
                        print("🛑 Workout stopped from watch controls")
                    }
                    .frame(height: 50)
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.bottom, 20)
            .background(Color("grayBackground"))
            .ignoresSafeArea()

    }

    // MARK: - Update Time
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        currentTime = formatter.string(from: Date())
    }
}

// MARK: - Workout Icon
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
       case .functionalStrengthTraining: return "figure.functional.training"
       default: return "figure.walk"
       }
   }


#Preview {
    WatchWorkoutControlsView()
        .environment(WorkoutSessionManager())
        .environment(WatchConnectivityManager())
}


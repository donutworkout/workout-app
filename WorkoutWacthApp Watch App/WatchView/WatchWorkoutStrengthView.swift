//
//  WatchWorkoutStrengthView.swift
//  WorkoutWatchApp Watch App
//
//  Created by Jennifer Evelyn on 05/11/25.
//

import SwiftUI
import HealthKit

struct WatchWorkoutStrengthView: View {
    @Environment(WorkoutSessionManager.self) private var sessionManager
    @Environment(WatchConnectivityManager.self) private var connectivity
    
    @State private var currentTime: String = Self.formatCurrentTime()
    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var clockActive = true

    var body: some View {
        ZStack {
            Color("grayBackground")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Bar
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: getWorkoutIcon(for: connectivity.selectedWorkoutType ?? .traditionalStrengthTraining))
                            .font(.system(size: 18))
                            .foregroundColor(Color("pinkTextPrimary"))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                
                Spacer()

                // MARK: - Character
                Image("buttercup")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.top, -20)

                // MARK: - Timer + Stats
                VStack(alignment: .leading, spacing: 8) {
                    // Timer tampil jam:menit:detik
                    Text(formatTime(Int(sessionManager.timeActive)))
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.bottom, 4)

                    StatRow(icon: "flame.fill", text: String(format: "%.0f kcal", sessionManager.activeEnergy))
                    StatRow(icon: "heart.fill", text: sessionManager.heartRate > 0
                            ? String(format: "%.0f bpm", sessionManager.heartRate): "-- bpm")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.top, 10)

                Spacer()
                    .padding(.bottom, 20)
            }
        }
        .onReceive(clockTimer) { _ in
            guard clockActive else { return }
            updateTime()
        }
        .onChange(of: sessionManager.isPaused) { _, paused in
            clockActive = !paused
        }
        .onAppear {
            if !sessionManager.isRunning {
                if let type = connectivity.selectedWorkoutType {
                    sessionManager.startWorkout(of: type, isIndoor: connectivity.selectedIsIndoor)
                } else {
                    sessionManager.startWorkout(of: .functionalStrengthTraining, isIndoor: true)
                }
            }
        }
        .onChange(of: sessionManager.isRunning) { _, running in
            if !running {
                print("⌚️ WATCH Strength STOP → sending to phone")
                connectivity.sendMessage([
                    "cmd": WorkoutCommand.stop.rawValue
                ])
            }
        }
    }

    // MARK: - Helpers
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        currentTime = formatter.string(from: Date())
    }
    
    private static func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    private func formatTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    private func getWorkoutIcon(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .traditionalStrengthTraining: return "figure.strengthtraining.traditional"
        case .functionalStrengthTraining: return "figure.strengthtraining.functional"
        default: return "figure.strengthtraining.traditional"
        }
    }
}

// MARK: - Small reusable row
private struct StatRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color("pinkTextPrimary"))
            Text(text)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    WatchWorkoutStrengthView()
        .environment(WorkoutSessionManager())
        .environment(WatchConnectivityManager())
}

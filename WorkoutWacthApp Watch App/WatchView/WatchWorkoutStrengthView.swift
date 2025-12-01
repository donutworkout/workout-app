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
        VStack(spacing: 0) {
            // MARK: - Top Bar
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: getWorkoutIcon(for: connectivity.selectedWorkoutType ?? .traditionalStrengthTraining))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("pinkTextPrimary"))
                }
                
                Spacer()
                
//                // Current time
//                Text(currentTime)
//                    .font(.system(size: 13, weight: .medium))
//                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            
            Spacer()
                .frame(height: 8)

            // MARK: - Character
            Image("charStrength")
                .resizable()
                .scaledToFit()
                .frame(height: 75)
                .padding(.bottom, 4)

            // MARK: - Timer (Centered & Prominent)
            Text(formatTime(Int(sessionManager.timeActive)))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .monospacedDigit()
                .padding(.bottom, 8)

            // MARK: - Stats
            VStack(alignment: .leading, spacing: 3) {
                StatRow(
                    icon: "flame.fill",
                    text: String(format: "%.0f kcal", sessionManager.activeEnergy)
                )
                
                StatRow(
                    icon: "heart.fill",
                    text: sessionManager.heartRate > 0
                        ? String(format: "%.0f bpm", sessionManager.heartRate)
                        : "-- bpm"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)

            Spacer()
                .frame(height: 12)
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
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("pinkTextPrimary"))
            
            Text(text)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    WatchWorkoutStrengthView()
        .environment(WorkoutSessionManager())
        .environment(WatchConnectivityManager())
}

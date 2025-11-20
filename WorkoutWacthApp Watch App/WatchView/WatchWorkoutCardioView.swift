//
//  WatchWorkoutCardioView.swift
//  WorkoutWatchApp Watch App
//
//  Created by Jennifer Evelyn on 04/11/25.
//

// page 2 dari start stop, page 1 nya di WatchWorkoutControlView

import SwiftUI
import HealthKit

struct WatchWorkoutCardioView: View {
    @Environment(WorkoutSessionManager.self) private var sessionManager
    @Environment(WatchConnectivityManager.self) private var connectivity
    
    let workoutType: HKWorkoutActivityType
    
    @State private var currentTime: String = Self.formatCurrentTime()
    @State private var clockActive = true
    
    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
                        
                        Image(systemName: getWorkoutIcon(for: connectivity.selectedWorkoutType ?? .running))
                            .font(.system(size: 18))
                            .foregroundColor(Color("pinkTextPrimary"))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                
                Spacer()

                // MARK: - Character
                Image("buttercup") // pastikan asset sama
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.top, -20)

                // MARK: - Timer + Stats
                VStack(alignment: .leading, spacing: 0) {
                    // Timer tampil jam:menit:detik
                    Text(formatTime(Int(sessionManager.timeActive)))
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.bottom, 4)

                    StatRow(icon: "flame.fill",
                            text: String(format: "%.0f kcal", sessionManager.activeEnergy))
                    StatRow(icon: "figure.walk",
                            text: String(format: "%.2f km", sessionManager.distance / 1000))
                    StatRow(
                        icon: "heart.fill",
                        text: sessionManager.heartRate > 0
                            ? String(format: "%.0f bpm", sessionManager.heartRate): "-- bpm"
                    )
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
            if connectivity.shouldStartWorkout,
               !sessionManager.isRunning {

                if let type = connectivity.selectedWorkoutType {
                    sessionManager.startWorkout(of: type,
                                                isIndoor: connectivity.selectedIsIndoor)
                    print("⌚ Auto-start workout from iPhone: \(type.displayName)")
                }
            }
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
    
    // MARK: - Update Time
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        currentTime = formatter.string(from: Date())
    }
    
    // MARK: - Format Functions
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
    
    
}

// MARK: - Small row component
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
    WatchWorkoutCardioView(workoutType: .running)
        .environment(WorkoutSessionManager())
        .environment(WatchConnectivityManager())
}

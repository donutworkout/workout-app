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
    
    @State private var clockActive = true
    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Bar (Same as Strength)
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
            .padding(.top, 4)
            
            Spacer()
                .frame(height: 8)

            // MARK: - Character (Dynamic based on workout type)
            Image(getCharacterImage(for: connectivity.selectedWorkoutType ?? workoutType))
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

            // MARK: - Stats (Same as Strength)
            VStack(alignment: .leading, spacing: 3) {
                StatRow(
                    icon: "flame.fill",
                    text: String(format: "%.0f kcal", sessionManager.activeEnergy)
                )
                
                // Show distance only for specific activities
                if shouldShowDistance(for: connectivity.selectedWorkoutType ?? workoutType) {
                    StatRow(
                        icon: getDistanceIcon(for: connectivity.selectedWorkoutType ?? workoutType),
                        text: formatDistance(sessionManager.distance, for: connectivity.selectedWorkoutType ?? workoutType)
                    )
                }
                
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
    
    // MARK: - Character Image Mapping
    private func getCharacterImage(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .badminton: return "charBadminton"
        case .basketball: return "charBasketball"
        case .volleyball: return "charVolleyball"
        case .tennis: return "charTennis"
        case .running: return "charOutdoorRun"
        case .walking: return "charOutdoorWalk"
        case .cycling: return "charCycling"
        case .swimming: return "charSwimming"
        default: return "charBadminton"
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
        default: return "figure.walk"
        }
    }
    
    // MARK: - Distance Helpers
    private func shouldShowDistance(for type: HKWorkoutActivityType) -> Bool {
        let distanceActivities: [HKWorkoutActivityType] = [
            .running, .walking, .cycling, .swimming
        ]
        return distanceActivities.contains(type)
    }
    
    private func getDistanceIcon(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .swimming: return "figure.pool.swim"
        case .walking: return "figure.walk"
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        default: return "figure.walk"
        }
    }
    
    private func formatDistance(_ meters: Double, for type: HKWorkoutActivityType) -> String {
        if type == .swimming {
            return String(format: "%.0f m", meters)
        } else {
            let km = meters / 1000
            return String(format: "%.2f km", km)
        }
    }
    
    // MARK: - Format Time
    private func formatTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

// MARK: - Stat Row Component
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

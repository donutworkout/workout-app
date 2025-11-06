//
//  WatchActiveWorkoutView.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 28/10/25.
//
import SwiftUI
import HealthKit

struct WatchActiveWorkoutView: View {
    @Environment var sessionManager: WorkoutSessionManager
    @Environment(\.dismiss) var dismiss
    
    let workoutType: HKWorkoutActivityType
    let workoutName: String
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var currentTime = ""
    @State private var currentTab = 0
    
    let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(workoutName)
                .font(.headline)
                .foregroundColor(.orange)
            
            VStack(spacing: 12) {
                MetricView(
                    icon: "heart.fill",
                    value: String(format: "%.0f", sessionManager.heartRate),
                    unit: "BPM"
                )
                
                MetricView(
                    icon: "figure.walk",
                    value: String(format: "%.2f", sessionManager.distance / 1000),
                    unit: "km"
                )
                
                MetricView(
                    icon: "flame.fill",
                    value: String(format: "%.0f", sessionManager.energyBurned),
                    unit: "kcal"
                )
                
                MetricView(
                    icon: "timer",
                    value: formatTimeDisplay(elapsedTime),
                    unit: ""
                )
            }
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .onReceive(clockTimer) { _ in
            updateCurrentTime()
        }
    }
    
    // MARK: - Helper Functions
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
    
    private func updateCurrentTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        currentTime = formatter.string(from: Date())
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if sessionManager.isRunning {
                elapsedTime += 1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTimeDisplay(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

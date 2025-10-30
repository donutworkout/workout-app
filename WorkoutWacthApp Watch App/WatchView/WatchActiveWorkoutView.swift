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
    
    var body: some View {
        VStack(spacing: 20) {
            // Workout Type
            Text(workoutName)
                .font(.headline)
                .foregroundColor(.orange)
            
            // Metrics - Using real data from WorkoutSessionManager
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
                    value: formatTime(elapsedTime),
                    unit: ""
                )
            }
            
            Spacer()
            
            // Controls
            HStack(spacing: 20) {
                Button {
                    // Pause/Resume functionality can be added to WorkoutSessionManager
                } label: {
                    Image(systemName: sessionManager.isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
                
                Button {
                    // Stop the workout session
                    sessionManager.stopWorkout()
                    // Navigate back
                    dismiss()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Start workout when view appears
            sessionManager.startWorkout(of: workoutType)
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
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
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

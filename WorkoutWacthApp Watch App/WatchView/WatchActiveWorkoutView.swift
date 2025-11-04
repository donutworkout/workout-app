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
        GeometryReader { geometry in
            ZStack {
                // MARK: - Background
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Top Bar (Icon & Time)
                    HStack {
                        // Workout Icon
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: getWorkoutIcon())
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.5))
                        }
                        
                        Spacer()
                        
                        // Current Time
                        Text(currentTime)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // MARK: - Character/Image Area
                    ZStack {
                        Image("buttercup") // Replace with your workout character
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * 0.35)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    
                    Spacer()
                    
                    // MARK: - Metrics Display
                    TabView(selection: $currentTab) {
                        // Page 1: Time Display
                        VStack(spacing: 12) {
                            Text(formatTimeDisplay(elapsedTime))
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.5))
                                    Text("\(Int(sessionManager.energyBurned))kcal")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "figure.walk")
                                        .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.5))
                                    Text(String(format: "%.1f", sessionManager.distance / 1000))
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("km")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.5))
                                    Text("\(Int(sessionManager.heartRate))")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("bpm")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }
                        .tag(0)
                        
                        // Page 2: Additional Metrics (if needed)
                        VStack(spacing: 12) {
                            Text("Stats")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Swipe for more")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: geometry.size.height * 0.35)
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(clockTimer) { _ in
            updateCurrentTime()
        }
        .onAppear {
            updateCurrentTime()
            sessionManager.startWorkout(of: workoutType)
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Helper Functions
    private func getWorkoutIcon() -> String {
        switch workoutType {
        case .running: return "figure.run"
        case .cycling: return "figure.outdoor.cycle"
        case .walking: return "figure.walk"
        case .swimming: return "figure.pool.swim"
        case .basketball: return "figure.basketball"
        case .tennis: return "figure.tennis"
        case .yoga: return "figure.yoga"
        case .traditionalStrengthTraining: return "figure.strengthtraining.traditional"
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

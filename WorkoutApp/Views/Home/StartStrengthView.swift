//
//  StartStrengthView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 27/10/25.
//

import SwiftUI

struct StartStrengthView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    private let phoneConnectivity = iPhoneConnectivityManager.shared
    
    var workoutName: String = "Bridge"
    var imageName: String = "bridge"
    var duration: TimeInterval = 60
    
    // Misal latihan ke-2 dari 5
    var currentPage: Int = 2
    var totalPages: Int = 5
    
    @State private var timeRemaining: TimeInterval = 60
    @State private var isPaused: Bool = false
    @State private var timer: Timer? = nil
    @State private var calories: Int = 0
    @State private var bpm: Int = 90
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Page Control + Title + Image
            VStack(spacing: 16) {
                // MARK: Page Control (bulatan)
                HStack(spacing: 6) {
                    ForEach(1...totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color("pinkTextPrimary") : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 24)
                
                // MARK: Workout Title
                Text(workoutName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Color("pinkTextPrimary"))
                
                // MARK: Image
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 320)
                    .padding(.top, 8)
            }
            
            Spacer()
            
            // MARK: - Timer
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(Color("pinkTextPrimary"))
                
                Text(formattedTime)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .monospacedDigit()
            }
            .padding(.bottom, 32)
            
            // MARK: - Stats Cards
            HStack(spacing: 12) {
                StatCardItem(icon: "flame.fill", value: "\(calories)", label: "KCAL")
                StatCardItem(icon: "heart.fill", value: "\(bpm)", label: "BPM")
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
            
            Spacer()
            
            // MARK: - Buttons
            HStack(spacing: 16) {
                NeutralGlassButton(title: isPaused ? "Resume" : "Pause") {
                    if isPaused {
                        phoneConnectivity.resumeWorkoutFromPhone()
                        isPaused = false
                    } else {
                        phoneConnectivity.pauseWorkoutFromPhone()
                        isPaused = true
                    }
                }
                
                NeutralGlassButton(title: "Next") {
                    phoneConnectivity.stopWorkoutFromPhone()
                    timer?.invalidate()
                    router.navigateTo(.restView)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    timer?.invalidate()
                    router.navigateTo(.menu)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear { startTimer() }
        .onDisappear { timer?.invalidate() }
    }
    
    // MARK: - Formatters
    private var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Timer Logic
    private func startTimer() {
        timeRemaining = duration
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if !isPaused {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    calories = Int((duration - timeRemaining) / 6)
                    bpm = 90 + Int.random(in: -4...6)
                } else {
                    t.invalidate()
                    handleTimerComplete()
                }
            }
        }
    }
    
    private func toggleTimer() {
        isPaused.toggle()
    }
    
    private func handleTimerComplete() {
        router.navigateTo(.restView)
    }
}


#Preview {
    NavigationStack {
        StartStrengthView()
            .environmentObject(Router())
    }
}

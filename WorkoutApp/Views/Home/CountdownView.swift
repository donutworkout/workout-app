//
//  CountdownView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 27/10/25.
//

import SwiftUI

struct CountdownView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    
    // MARK: - Props
    var workoutName: String = "gluteBridge"
    var imageName: String = "gluteBridge"
    var duration: TimeInterval = 60
    var onCountdownComplete: () -> Void = {}
    
    // Page control (opsional, sesuaikan dengan kebutuhan)
    var currentPage: Int = 1
    var totalPages: Int = 5
    
    @State private var countdown: Int = 3
    @State private var showCountdown: Bool = true
    @State private var timeRemaining: TimeInterval = 60
    @State private var isPaused: Bool = false
    @State private var timer: Timer? = nil
    @State private var calories: Int = 0
    @State private var bpm: Int = 90
    
    init(workoutName: String = "gluteBridge",
         imageName: String = "gluteBridge",
         duration: TimeInterval = 60,
         currentPage: Int = 1,
         totalPages: Int = 5,
         onCountdownComplete: @escaping () -> Void = {}) {
        self.workoutName = workoutName
        self.imageName = imageName
        self.duration = duration
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.onCountdownComplete = onCountdownComplete
    }
    
    var body: some View {
        ZStack {
            // MARK: - Base Workout View (sama seperti StartStrengthView)
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
                
                // MARK: - Buttons (hidden during countdown)
                if !showCountdown {
                    HStack(spacing: 16) {
                        NeutralGlassButton(title: isPaused ? "Resume" : "Pause") {
                            isPaused.toggle()
                        }
                        
                        NeutralGlassButton(title: "Next") {
                            timer?.invalidate()
                            router.navigateTo(.restView)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.white.ignoresSafeArea())
            
            // MARK: - Countdown Overlay
            if showCountdown {
                ZStack {
                    // Semi-transparent overlay
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    // Countdown number
                    Text("\(countdown)")
                        .font(.system(size: 120, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .transition(.opacity)
            }
        }
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
        .onAppear { startCountdown() }
        .onDisappear { timer?.invalidate() }
    }
    
    // MARK: - Formatters
    private var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Countdown Logic
    private func startCountdown() {
        countdown = 3
        showCountdown = true
        timeRemaining = duration
        
        // Countdown overlay timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if countdown > 1 {
                countdown -= 1
            } else {
                t.invalidate()
                
                // Start workout on countdown completion
                if let type = router.selectedWorkoutType {
                    iPhoneConnectivityManager.shared.startWorkoutFromPhone(type: type)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showCountdown = false
                    }
                    onCountdownComplete()
                    
                    // Start workout timer after countdown
                    startWorkoutTimer()
                }
            }
        }
    }
    
    // MARK: - Workout Timer Logic
    private func startWorkoutTimer() {
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
    
    private func handleTimerComplete() {
        router.navigateTo(.restView)
    }
}

#Preview {
    NavigationStack {
        CountdownView()
            .environmentObject(Router())
    }
}

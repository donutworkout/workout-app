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
    var workoutName: String = "Bridge"
    var reps: String = "3 x 12"
    var imageName: String = "bridge"
    var onCountdownComplete: () -> Void = {}
    
    @State private var countdown: Int = 3
    @State private var showCountdown: Bool = true
    @State private var timeElapsed: TimeInterval = 0
    @State private var isPaused: Bool = false
    @State private var timer: Timer? = nil

    init(onCountdownComplete: @escaping () -> Void = {}) {
        self.onCountdownComplete = onCountdownComplete
    }

    var body: some View {
        ZStack {
            // MARK: - Base Workout View (StartStrengthView content)
            VStack(spacing: 20) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 320)
                    .padding(.top, 40)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Text(workoutName)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(Color("pinkTextPrimary"))
                    
                    Text(formattedTime)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color("pinkTextPrimary"))
                        .padding(.top, 8)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    NeutralGlassButton(title: isPaused ? "Resume" : "Pause") {
                        toggleTimer()
                    }
                    
                    NeutralGlassButton(title: "Next") {
                        timer?.invalidate()
                        router.navigateTo(.menu)
                    }
                }
                .padding(.bottom, 40)
                .padding(.horizontal)
            }
            .background(Color.white.ignoresSafeArea())
            
            // MARK: - Countdown Overlay
            if showCountdown {
                ZStack {
                    // Semi-transparent gray overlay
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

    // MARK: - Time Formatting
    private var formattedTime: String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Countdown Logic
    private func startCountdown() {
        countdown = 3
        showCountdown = true
        
        // Start workout timer immediately in background
        startWorkoutTimer()
        
        // Countdown overlay timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if countdown > 1 {
                countdown -= 1
            } else {
                t.invalidate()
                withAnimation(.easeOut(duration: 0.3)) {
                    showCountdown = false
                }
                onCountdownComplete()
            }
        }
    }

    // MARK: - Workout Timer Logic
    private func startWorkoutTimer() {
        timeElapsed = 0
        isPaused = false
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if !isPaused && !showCountdown {
                timeElapsed += 1
            }
            
            // Store reference only after countdown
            if !showCountdown && timer == nil {
                timer = t
            }
        }
    }

    private func toggleTimer() {
        isPaused.toggle()
    }
}

#Preview {
    NavigationStack {
        CountdownView()
            .environmentObject(Router())
    }
}

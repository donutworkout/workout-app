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
    @EnvironmentObject var sessionManager: StrengthSessionManager
    
    let exercises: [Exercise]
    
    @State private var countdown: Int = 3
    @State private var showCountdown: Bool = true
    @State private var timeRemaining: TimeInterval = 0
    @State private var showPausePopup: Bool = false
    @State private var showExitAlert: Bool = false
    @State private var isPaused: Bool = false
    @State private var timer: Timer? = nil
    @State private var calories: Int = 0
    @State private var bpm: Int = 90
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var firstExercise: Exercise? {
        exercises.first
    }
    
    var totalPages: Int {
        exercises.count
    }
    
    init(exercises: [Exercise], onCountdownComplete: @escaping () -> Void = {}) {
        self.exercises = exercises
    }
    
    var body: some View {
        ZStack {
            // MARK: - Base Workout View (sama seperti StartStrengthView)
            VStack(spacing: 0) {
                // MARK: - Page Control + Title + Image
                VStack(spacing: 16) {
                    // MARK: Workout Title
                    Text(firstExercise?.name ?? "Get Ready!")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color("pinkTextPrimary"))
                        .pageHeaderAnimation(delay: 0.1)
                    
                    // MARK: Image
                    if let imageName = firstExercise?.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 320)
                            .padding(.top, 8)
                            .pageImageAnimation(delay: 0.2)
                    }
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
                .pageCardAnimation(delay: 0.3)
                
                // MARK: - Stats Cards
                HStack(spacing: 12) {
                    StatCardItem(icon: "flame.fill", value: "\(calories)", label: "KCAL")
                    StatCardItem(icon: "heart.fill", value: "\(bpm)", label: "BPM")
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
                .pageCardAnimation(delay: 0.4)
                
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
                    .disabled(showPausePopup)
                    .pageCardAnimation(delay: 0.5)
                }
                
                // MARK: - Pause Popup
                if showPausePopup {
                    Alert(
                        characterImage: "characterFreeze",
                        onResume:  {
                                showExitAlert = false
                            
                        },
                        onEndWorkout: {
                            timer?.invalidate()
                            router.navigateTo(.menu)
                        }
                    )
                }
            }
            .background(Color.white.ignoresSafeArea())
            
            // MARK: - Countdown Overlay
            if showCountdown {
                ZStack {
                    // Semi-transparent overlay
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Teks "Get Ready!"
//                        Text("Get Ready!")
//                            .font(.system(size: 22, weight: .semibold, design: .rounded))
//                            .foregroundColor(.white.opacity(0.9))
//                            .textCase(.uppercase)
//                            .tracking(1)
//                            .padding(.bottom, 20)
                        
                        // Countdown number + circle
                        ZStack {
                            Circle()
                                .stroke(Color("pinkTextPrimary").opacity(0.9), lineWidth: 4)
                                .frame(width: 150, height: 150)
                            
                            Circle()
                                .fill(Color("pinkTextPrimary").opacity(0.9))
                                .frame(width: 122, height: 122)
                            
                            Text("\(countdown)")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.7))
                                .monospacedDigit()
                        }
                        .scaleEffect(scale)
                        .opacity(opacity)
                        
//                        Spacer()
//                        
//                        // Hint bawah
//                        Text("Starting workout...")
//                            .font(.system(size: 14, weight: .medium))
//                            .foregroundColor(.white.opacity(0.7))
//                            .padding(.top, 24)
                    }
                    .padding(.bottom, 60)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .transition(.opacity)
                // --- Handle animation on appear/change
                .onAppear {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.62)) {
                        scale = 1.0
                        opacity = 1.0
                    }
                }
                .onChange(of: countdown) { _, _ in
                    scale = 0.78
                    opacity = 0.5
                    withAnimation(.spring(response: 0.31, dampingFraction: 0.7)) {
                        scale = 1.0
                        opacity = 1.0
                    }
                    // Haptic feedback, sound, etc can go here
                }
            }
        }
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    // Instead of navigating directly → show alert first
                    showPausePopup = true
                    isPaused = true
                    timer?.invalidate()
                    router.navigateTo(.menu)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            startCountdown()
        }
        //.onDisappear { timer?.invalidate() }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            SoundManager.shared.playSound("countdownMusic", withExtension: "mp3")
            }
        HapticManager.shared.trigger(.countdownTick)
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            countdown -= 1  // ✅ 3→2→1→0
            
            if countdown > 0 {
                // Still counting
                HapticManager.shared.trigger(.countdownTick)
            } else {
                t.invalidate()
                HapticManager.shared.trigger(.countdownEnd)
                
                if let type = router.selectedWorkoutType {
                    iPhoneConnectivityManager.shared.startWorkoutFromPhone(type: type, isIndoor: true)
                }
                
                StrengthSessionManager.shared.beginWorkout()
                
                withAnimation(.easeOut(duration: 0.3)) {
                    showCountdown = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { 
                    print("🚀 Navigating to StartStrengthView")
                    router.navigateTo(.startStrength)
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
                    // calories = Int((duration - timeRemaining) / 6)
                    bpm = 90 + Int(timeRemaining.truncatingRemainder(dividingBy: 30))
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

//#Preview {
//    NavigationStack {
//        CountdownView()
//            .environmentObject(Router())
//    }
//}

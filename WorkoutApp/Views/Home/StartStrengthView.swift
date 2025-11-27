//
//  StartStrengthView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 27/10/25.
//

import SwiftUI
import SwiftData

struct StartStrengthView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    //@EnvironmentObject var sessionManager: StrengthSessionManager
    
    private let sessionManager = StrengthSessionManager.shared
    private let connectivity = iPhoneConnectivityManager.shared
    
    @Query private var userProfiles: [UserProfile]
    
    // Misal latihan ke-2 dari 5
    var currentPage: Int = 1
    var totalPages: Int = 5
    var durationGoal: Int = 30
    
    private var userProfile: UserProfile? {
        userProfiles.first
    }
    
    @State private var timeRemaining: TimeInterval = 60
    @State private var isPaused: Bool = false
    @State private var timer: Timer? = nil
    @State private var calories: Int = 0
    @State private var bpm: Int = 0
    @State private var lastExerciseIndex: Int = 0
    
    @State private var showPausePopup: Bool = false
    @State private var showHRAlert: Bool = false
    
    var currentExercise: Exercise? {
        sessionManager.currentExercise
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Page Control + Title + Image
                VStack(spacing: 16) {
                    // MARK: Workout Title
                    Text(currentExercise?.name ?? "Get Ready!")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color("pinkTextPrimary"))
                    
                    // MARK: Image
                    if let imageName = currentExercise?.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 320)
                            .padding(.top, 8)
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
                
                // MARK: - Stats Cards
                HStack(spacing: 12) {
                    StatCardItem(icon: "flame.fill", value: "\(calories)", label: "KCAL")
                    StatCardItem(icon: "heart.fill", value: connectivity.heartRate > 0 ? "\(bpm)" : "120",
                                 label: "BPM")
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
                
                Spacer()
                
                // MARK: - Buttons
                HStack(spacing: 16) {
                    NeutralGlassButton(title: isPaused ? "Resume" : "Pause") {
                        if isPaused {
                            isPaused = false
                            showPausePopup = false
                        } else {
                            isPaused = true
                            showPausePopup = true
                        }
                    }
                    
                    NeutralGlassButton(title: "Next") {
                        //                    router.navigateTo(.restView)
                        
                        if sessionManager.hasNextExercise {
                            // Go to rest view, then next exercise
                            router.navigateTo(.restView)
                        } else {
                            // Workout complete - go to summary or home
                            connectivity.stopWorkoutFromPhone()
                            sessionManager.reset()
                            router.navigateTo(.finishWorkout)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            if showPausePopup {
                Alert(
                    characterImage: "characterFreeze",
                    onResume: {
                        showPausePopup = false
                        isPaused = false
                        connectivity.resumeWorkoutFromPhone()
                    },
                    onEndWorkout: {
                        timer?.invalidate()
                        connectivity.stopWorkoutFromPhone()
                        showPausePopup = false
                        isPaused = false
                        router.navigateTo(.halfwayWorkout)
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
            }
            
            if showHRAlert {
                ZStack {
                    // ✅ Full screen overlay
                    Color.white.opacity(0.5)
                        .ignoresSafeArea(.all) // ✅ Cover everything including safe areas
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showHRAlert = false
                            }
                        }
                    
                    // ✅ Alert Dialog
                    VStack(spacing: 0) {
                        // MARK: - Content Area
                        VStack(spacing: 12) {
                            // Title
                            Text("Maximum HR Reached")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            // Message
                            Text("You've reached your max HR, please slow down:)")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        
                        Divider()
                        
                        // MARK: - Button
                        Button(action: {
                            withAnimation(.spring()) {
                                showHRAlert = false
                                isPaused = false
                            }
                        }) {
                            Text("OK")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color("pinkTextPrimary"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .contentShape(Rectangle())
                        }
                    }
                    .frame(width: 270)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                }
                .transition(.opacity.combined(with: .scale(scale: 1.1)))
                .zIndex(999) // ✅ Ensure it's on top
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    showPausePopup = true
                    isPaused = true
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            if sessionManager.isRunning {
                if timer == nil || lastExerciseIndex != sessionManager.currentExerciseIndex {
                    lastExerciseIndex = sessionManager.currentExerciseIndex
                    startTimer()
                }
            }
            
        }
        .onChange(of: connectivity.isWorkoutActive) { _, active in
            print("onchange isWorkoutActive: \(active)")

            if !active {
                print("🏁 STOP from watch → navigate FinishWorkout")
                timer?.invalidate()
                sessionManager.reset()
                router.navigateTo(.finishWorkout)
            }
        }
        .onChange(of: connectivity.isWorkoutPaused) { _, paused in
            if paused {
                showPausePopup = true
            } else {
                showPausePopup = false
            }
        }
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
        timer?.invalidate()
        
        if let duration = currentExercise?.time {
            timeRemaining = TimeInterval(duration)
                
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
                if !isPaused {
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                        calories = Int(connectivity.energyBurned)
                        bpm = connectivity.heartRate > 0 ? Int(connectivity.heartRate) : 0
                        
                        if countMaximumHR() && !showHRAlert {
                            showHRAlert = true
                            isPaused = true  // Auto-pause when max HR exceeded
                        }
                    } else {
                        t.invalidate()
                        handleTimerComplete()
                    }
                }
            }
        } else {
            timeRemaining = 0
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
                if !isPaused {
                    timeRemaining += 1
                    calories = Int(connectivity.energyBurned)
                    bpm = connectivity.heartRate > 0 ? Int(connectivity.heartRate) : 0
                    
                    if countMaximumHR() && !showHRAlert {
                        showHRAlert = true
                        isPaused = true  // Auto-pause when max HR exceeded
                    }
                }
            }
        }
    }
    
    private func toggleTimer() {
        isPaused.toggle()
    }
    
    private func handleTimerComplete() {
        timer?.invalidate()
        router.navigateTo(.restView)
    }
    
    private func countMaximumHR() -> Bool {
        let age = Double(userProfile?.age ?? 0)
        let maxHR = Int(208.0 - (0.7 * age))
        return bpm >= maxHR
    }
}


//#Preview {
//    NavigationStack {
//        StartStrengthView()
//            .environmentObject(Router())
//    }
//}


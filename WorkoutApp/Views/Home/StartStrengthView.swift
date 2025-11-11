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
    //@EnvironmentObject var sessionManager: StrengthSessionManager
    
    private let sessionManager = StrengthSessionManager.shared
    private let phoneConnectivity = iPhoneConnectivityManager.shared
    
    // Misal latihan ke-2 dari 5
    var currentPage: Int = 1
    var totalPages: Int = 5
    
    @State private var timeRemaining: TimeInterval = 60
    @State private var isPaused: Bool = false
    @State private var timer: Timer? = nil
    @State private var calories: Int = 0
    @State private var bpm: Int = 90
    @State private var lastExerciseIndex: Int = 0
    
    var currentExercise: Exercise? {
        sessionManager.currentExercise
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Page Control + Title + Image
            VStack(spacing: 16) {
                // MARK: Page Control (bulatan)
//                HStack(spacing: 6) {
//                    ForEach(1...sessionManager.totalPages, id: \.self) { index in
//                        Circle()
//                            .fill(index == sessionManager.currentPage ? Color("pinkTextPrimary") : Color.gray.opacity(0.3))
//                            .frame(width: 8, height: 8)
//                    }
//                }
//                .padding(.top, 24)
                
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
                    //                    phoneConnectivity.stopWorkoutFromPhone()
                    //                    timer?.invalidate()
                    //                    router.navigateTo(.restView)
                    
                    if sessionManager.hasNextExercise {
                        // Go to rest view, then next exercise
                        router.navigateTo(.restView)
                    } else {
                        // Workout complete - go to summary or home
                        phoneConnectivity.stopWorkoutFromPhone()
                        sessionManager.reset()
                        router.navigateTo(.menu)
                    }
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
        .onAppear {
            if timer == nil || lastExerciseIndex != sessionManager.currentExerciseIndex {
                lastExerciseIndex = sessionManager.currentExerciseIndex
                startTimer()
            }
        }
        .onDisappear { timer?.invalidate() }
//        .onChange(of: sessionManager.currentExerciseIndex) { _, _ in
//            // Reset timer for new exercise
//            timer?.invalidate()
//            startTimer()
//            calories = 0
//        }
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
        
        let duration: TimeInterval = TimeInterval(currentExercise?.time ?? 60)
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


//#Preview {
//    NavigationStack {
//        StartStrengthView()
//            .environmentObject(Router())
//    }
//}

//
//  RestView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 27/10/25.
//

import SwiftUI

struct RestView: View {
    @Environment(\.dismiss) private var dismiss
    var onNext: () -> Void = {}
    @EnvironmentObject var router: Router
    
    private let sessionManager = StrengthSessionManager.shared
    
    var level: WorkoutLevel
    @State private var timer: Timer? = nil
    @State private var isTooMuchPaused: Bool = false
    @State private var timeRemaining: TimeInterval = 0
    @State private var isPaused: Bool = false
    
    var nextWorkoutName: Exercise? {
        if sessionManager.hasMoreSets {
            return sessionManager.currentExercise
        } else {
            return sessionManager.nextExercise
        }
    }
    
    var nextWorkoutNumber: Int {
        if sessionManager.hasMoreSets {
            return sessionManager.currentPage
        } else {
            return sessionManager.currentPage + 1
        }
    }
    
    var nextSetInfo: String {
        if sessionManager.hasMoreSets {
            return "Set \(sessionManager.currentSetNumber + 1)/\(sessionManager.currentExercise?.sets ?? 1)"
        } else {
            return "Next Exercise"
        }
    }
    
    var totalWorkouts: Int = 7
    
    var restDuration: TimeInterval {
        switch level {
        case .beginner:
            return 60
        case .intermediate:
            return 45
        case .advanced:
            return 30
        }
    }
    
    private var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Rest Timer
            VStack(spacing: 16) {
                Text("Rest")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .pageHeaderAnimation(delay: 0.1)  // Animasi header
                
                Text(formattedTime)
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .pageCardAnimation(delay: 0.2)    // Animasi angka timer
                
                Text(isTooMuchPaused ? "⚠️ You’ve added too much rest time!" : " ")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isTooMuchPaused ? .red : .clear)
                    .animation(.easeInOut(duration: 0.3), value: isTooMuchPaused)
            }
            .padding(.vertical, 40)
            
            Spacer()
            
            // MARK: - Next Workout Preview
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(sessionManager.hasMoreSets ? nextSetInfo : "Next \(nextWorkoutNumber)/\(totalWorkouts)")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                        .pageHeaderAnimation(delay: 0.3) // Animasi teks preview
                    
                    Spacer()
                }
                
                if let next = nextWorkoutName {
                    Text(next.name)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .pageCardAnimation(delay: 0.4)  // Animasi nama workout
                    
                    // Next workout image with pink background
                    Image(next.imageName ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color("pinkTextPrimary").opacity(0.15))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .pageImageAnimation(delay: 0.5)  // Animasi gambar workout
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            
            HStack(spacing: 16) {
                NeutralGlassButton(title: "+10s") {
                    HapticManager.shared.trigger(.buttonTap)
                    switch timeRemaining {
                    case 111...119:
                        timeRemaining += (120 - timeRemaining)
                    case 120:
                        isTooMuchPaused = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isTooMuchPaused = false
                        }
                        HapticManager.shared.trigger(.restAdded)
                    default:
                        timeRemaining += 10
                    }
                }
                
                NeutralGlassButton(title: nextWorkoutName != nil ? "Next" : "Finish") {
                    timer?.invalidate()
                    timer = nil
                    
                    if nextWorkoutName != nil {
                        sessionManager.moveToNextExercise()
                        print("⏭️ Moving to exercise: \(sessionManager.currentExercise?.name ?? "nil")")
                        router.navigateTo(.startStrength)
                    } else {
                        // Workout complete
                        iPhoneConnectivityManager.shared.stopWorkoutFromPhone()
                        sessionManager.reset()
                        router.navigateTo(.menu)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
            .pageCardAnimation(delay: 0.6)   // Animasi tombol
            
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            HapticManager.shared.trigger(.restStart) // ✅ haptic saat mulai rest
            startRestTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func startRestTimer() {
        timeRemaining = restDuration
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if !isPaused && timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining == 0 {
                t.invalidate()
                HapticManager.shared.trigger(.countdownEnd)
                onNext()
                
                if nextWorkoutName != nil {
                    sessionManager.moveToNextExercise()
                    print("⏰ Auto-advancing to: \(sessionManager.currentExercise?.name ?? "nil")")
                    router.navigateTo(.startStrength)
                } else {
                    // Workout complete
                    iPhoneConnectivityManager.shared.stopWorkoutFromPhone()
                    sessionManager.reset()
                    router.navigateTo(.menu)
                }
            }
        }
    }
}

//#Preview {
//    NavigationStack {
//        RestView()
//    }
//}

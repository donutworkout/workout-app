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
    
    @State private var timer: Timer? = nil
    
    var nextWorkoutName: Exercise? {
        sessionManager.nextExercise
    }
    
    var nextWorkoutNumber: Int {
        sessionManager.currentPage + 1
    }
    
    var restDuration: TimeInterval = 30
    //var nextWorkoutNumber: Int = 2
    var totalWorkouts: Int = 7
    
    @State private var timeRemaining: TimeInterval = 30
    @State private var isPaused: Bool = false
    
    private var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // MARK: - Rest Timer
            VStack(spacing: 16) {
                Text("Rest")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(Color("pinkTextPrimary"))
                
                Text(formattedTime)
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(Color("pinkTextPrimary"))
            }
            .padding(.vertical, 40)
            
            Spacer()
            
            // MARK: - Next Workout Preview
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Next \(nextWorkoutNumber)/\(totalWorkouts)")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                    Spacer()
                }
                
                if let next = nextWorkoutName {
                    Text(next.name)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
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
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            
            HStack(spacing: 16) {
                NeutralGlassButton(title: "+10s") {
                    timeRemaining += 10
                }

//                NeutralGlassButton(title: "Next") {
//                    timeRemaining = 0
//                    
//                    DispatchQueue.main.async {
//                        router.navigateTo(.startStrength)
//                    }
//                }
                NeutralGlassButton(title: nextWorkoutName != nil ? "Next" : "Finish") {
                    timer?.invalidate() // ✅ Stop timer
                    timer = nil
                    
                    if nextWorkoutName != nil {
                        sessionManager.moveToNextExercise() // ✅ Move to next BEFORE navigating
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
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startRestTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func startRestTimer() {
        timeRemaining = 30
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if !isPaused && timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining == 0 {
                t.invalidate()
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

#Preview {
    NavigationStack {
        RestView()
    }
}

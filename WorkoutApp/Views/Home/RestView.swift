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
    
    // MARK: - Props
    var restDuration: TimeInterval = 30
    var nextWorkoutNumber: Int = 2
    var totalWorkouts: Int = 7
    var nextWorkoutName: String = "Wall Press"
    var nextWorkoutImage: String = "wallPress"
    
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
                
                Text(nextWorkoutName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Next workout image with pink background
                Image(nextWorkoutImage)
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
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            
            // MARK: - Bottom Buttons
            HStack(spacing: 16) {
                NeutralGlassButton(title: "+10s") {
                    timeRemaining += 10
                }

                NeutralGlassButton(title: "Next") {
                    router.navigateTo(.menu)
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
    }
    
    // MARK: - Timer Logic
    private func startRestTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if !isPaused && timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining == 0 {
                timer.invalidate()
                onNext()
            }
        }
    }
}

#Preview {
    NavigationStack {
        RestView()
    }
}

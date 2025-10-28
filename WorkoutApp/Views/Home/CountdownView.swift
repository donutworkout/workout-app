//
//  CountdownView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 27/10/25.
//

import SwiftUI

struct CountdownView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Props
    var workoutName: String = "Jumping Jack"
    var reps: String = "12X"
    var imageName: String = "jumpingJack"
    var currentSet: Int = 3
    var totalSets: Int = 7
    
    @State private var countdown: Int = 3
    @State private var isPaused: Bool = false
    
    var body: some View {
        ZStack {
            // MARK: - Main Workout Layout
            VStack(spacing: 0) {
                // MARK: - Progress Dots
                HStack(spacing: 8) {
                    ForEach(0..<totalSets, id: \.self) { index in
                        Circle()
                            .fill(index < currentSet ? Color("grayTextPrimary") : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 24)
                
                Spacer()
                
                // MARK: - Workout Info
                VStack(spacing: 12) {
                    Text(workoutName)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(Color("pinkTextPrimary"))
                    
                    Text(reps)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(Color("pinkTextPrimary"))
                }
                .padding(.top, 20)
                
                // MARK: - Image
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 400)
                    .padding(.vertical, 20)
                
                Spacer()
                
                // MARK: - Bottom Buttons
                HStack(spacing: 16) {
                    NeutralGlassButton(title: isPaused ? "Resume" : "Pause") {
                        isPaused.toggle()
                    }
                    
                    NeutralGlassButton(title: "Next") {
                        // Handle next action
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
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(10)
                    }
                }
            }
            
            // MARK: - Full Screen Countdown Overlay
            if countdown > 0 {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                Text("\(countdown)")
                    .font(.system(size: 200, weight: .bold))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .transition(.scale)
            }
        }
        .onAppear {
            startCountdown()
        }
    }
    
    // MARK: - Countdown Logic
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if !isPaused && countdown > 0 {
                countdown -= 1
            } else if countdown == 0 {
                timer.invalidate()
                // Transition ke workout berikutnya bisa kamu tambahkan di sini
            }
        }
    }
}

#Preview {
    NavigationStack {
        CountdownView()
    }
}

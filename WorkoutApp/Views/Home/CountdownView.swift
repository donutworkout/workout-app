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
    var workoutName: String = "Jumping Jack"
    var reps: String = "12X"
    var imageName: String = "jumpingJack"
    var currentSet: Int = 1
    var totalSets: Int = 7
    var onCountdownComplete: () -> Void = {}
    
    @State private var countdown: Int = 3
    @State private var isPaused: Bool = false
    @State private var timer: Timer? = nil
    
    init(onCountdownComplete: @escaping () -> Void = {}) {
        self.onCountdownComplete = onCountdownComplete
    }

    
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
                
                // MARK: - Bottom Buttons (hidden during countdown)
                if countdown == 0 {
                    HStack(spacing: 16) {
                        NeutralGlassButton(title: isPaused ? "Resume" : "Pause") {
                            isPaused.toggle()
                        }
                        
                        NeutralGlassButton(title: "Start") {
                            timer?.invalidate()
                            onCountdownComplete()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
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
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Countdown Logic
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if !isPaused && countdown > 0 {
                countdown -= 1
            } else if countdown == 0 {
                t.invalidate()
                // Auto-transition setelah hitung selesai
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // ✅ arahkan ke view sesuai asalnya
                    if let last = router.lastWorkoutSource {
                        switch last {
                        case .adjustMenuCardio:
                            router.navigateTo(.startCardio)
                        case .adjustMenuStrength:
                            router.navigateTo(.startStrength)
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CountdownView()
    }
}

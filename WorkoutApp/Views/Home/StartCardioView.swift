//
//  StartCardioView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 27/10/25.
//

import SwiftUI

struct StartCardioView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    @Environment(iPhoneConnectivityManager.self) private var connectivity
    
    // MARK: - Props
    var activityName: String = "Indoor Walk"
    var imageName: String = "indoorWalk"
    
    @State private var timeElapsed: TimeInterval = 0
    @State private var calories: Int = 0
    @State private var distance: Double = 0.0
    @State private var bpm: Int = 90
    @State private var isPaused: Bool = false
    @State private var showPausePopup: Bool = false
    
    @State private var timer: Timer? = nil
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Title and Image
                VStack(spacing: 16) {
                    Text(activityName)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color("pinkTextPrimary"))
                        .padding(.top, 16)
                    
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
                
                // MARK: - Stats
                HStack(spacing: 12) {
                    StatCardItem(icon: "flame.fill", value: "\(calories)", label: "KCAL")
                    StatCardItem(icon: "figure.walk", value: String(format: "%.1f", distance), label: "KILOMETERS")
                    StatCardItem(icon: "heart.fill", value: "\(bpm)", label: "BPM")
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
                
                Spacer()
                
                // MARK: - Button
                PrimaryGlassButton(title: isPaused ? "Resume" : "Pause") {
                    if isPaused {
                        // ✅ Resume workout
                        connectivity.resumeWorkoutFromPhone()
                        isPaused = false
                        showPausePopup = false
                    } else {
                        // ✅ Pause workout
                        connectivity.pauseWorkoutFromPhone()
                        
                        // ✅ Tampilkan alert/popup
                        isPaused = true
                        showPausePopup = true
                    }
                    isPaused.toggle()
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .blur(radius: showPausePopup ? 3 : 0)
            .disabled(showPausePopup)
            
            if showPausePopup {
                Alert(
                    characterImage: "",
                    onResume: {
                        showPausePopup = false
                        isPaused = false
                    },
                    onEndWorkout: {
                        timer?.invalidate()
                        router.navigateTo(.menu)
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Cardio Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    // Instead of navigating directly → show alert first
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
            print("connectivity \(connectivity.isWorkoutActive)")
            startTimer()
        }
        .onDisappear { timer?.invalidate() }
        .onChange(of: connectivity.isWorkoutActive) { _, active in
            print("onchange isWorkoutActive: \(connectivity.isWorkoutActive)")
            if !active {
                print(
                    "🏁 Workout stopped from watch → showing FinishWorkoutView"
                )
                router.navigateTo(.finishWorkout)
            }
        }
    }
    
    private var formattedTime: String {
        let hours = Int(connectivity.timeActive) / 3600
        let minutes = (Int(connectivity.timeActive) % 3600) / 60
        let seconds = Int(connectivity.timeActive) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            _ in
            if !isPaused {
                timeElapsed += 1
                calories = Int(timeElapsed / 15)
                distance = Double(timeElapsed) / 600.0
                bpm = 90 + Int(timeElapsed.truncatingRemainder(dividingBy: 30))
            }
        }
    }
}

// #Preview {
//     NavigationStack {
//         StartCardioView()
//             .environmentObject(Router())
//     }
// }

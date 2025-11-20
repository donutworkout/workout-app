//
//  CountdownCardioView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 09/11/25.
//

import SwiftUI

struct CountdownCardioView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    @Environment(iPhoneConnectivityManager.self) private var connectivity
    
    // MARK: - Props
    var activityName: String = "Indoor Walk"
    var imageName: String = "indoorWalk"
    var onCountdownComplete: () -> Void = {}
    
    @State private var countdown: Int = 3
    @State private var showCountdown: Bool = true
    @State private var timeElapsed: TimeInterval = 0
    @State private var calories: Int = 0
    @State private var distance: Double = 0.0
    @State private var bpm: Int = 90
    @State private var isPaused: Bool = false
    @State private var showPausePopup: Bool = false
    @State private var showExitAlert: Bool = false
    @State private var timer: Timer? = nil
    
    init(activityName: String = "Indoor Walk",
         imageName: String = "indoorWalk",
         onCountdownComplete: @escaping () -> Void = {}) {
        self.activityName = activityName
        self.imageName = imageName
        self.onCountdownComplete = onCountdownComplete
    }
    
    var body: some View {
        ZStack {
            // MARK: - Base Cardio View (sama persis dengan StartCardioView)
            VStack {
                VStack(spacing: 0) {
                    // MARK: - Image
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 380)
                        .padding(.top, 20)
                    
                    Text(formattedTime)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color("pinkTextPrimary"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.15), radius: 6, x: 0, y: 3)
                )
                .padding(.horizontal)
                
                // MARK: - Stats
                HStack(spacing: 16) {
                    StatCardItem(icon: "flame.fill", value: "\(calories)", label: "KCAL")
                    StatCardItem(icon: "figure.walk", value: String(format: "%.1f", distance), label: "KILOMETERS")
                    StatCardItem(icon: "heart.fill", value: "\(bpm)", label: "BPM")
                }
                .padding(.horizontal)
                
                Spacer()
                
                // MARK: - Button (hidden during countdown)
                if !showCountdown {
                    PrimaryGlassButton(title: isPaused ? "Resume" : "Pause") {
                        if isPaused {
                            connectivity.resumeWorkoutFromPhone()
                        } else {
                            connectivity.pauseWorkoutFromPhone()
                        }
                        isPaused.toggle()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                    .disabled(showPausePopup)
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
                    
                    // Countdown number
                    Text("\(countdown)")
                        .font(.system(size: 120, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .transition(.opacity)
            }
        }
        .navigationTitle(activityName)
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
        .onAppear { startCountdown() }
        .onDisappear { timer?.invalidate() }
    }
    
    // MARK: - Time Formatting
    private var formattedTime: String {
        let hours = Int(timeElapsed) / 3600
        let minutes = (Int(timeElapsed) % 3600) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // MARK: - Countdown Logic
    private func startCountdown() {
        countdown = 3
        showCountdown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            SoundManager.shared.playSound("countdownMusic", withExtension: "mp3")
            }
        HapticManager.shared.trigger(.countdownTick)
        
        // Countdown overlay timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            countdown -= 1  // ✅ 3→2→1→0
            
            if countdown > 0 {
                HapticManager.shared.trigger(.countdownTick)
            } else {
                t.invalidate()
                HapticManager.shared.trigger(.countdownEnd)
                if let type = router.selectedWorkoutType {
                    connectivity.startWorkoutFromPhone(type: type)
                }
                
                withAnimation(.easeOut(duration: 0.3)) {
                    showCountdown = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {  // ✅ Match animation duration
                    onCountdownComplete()
                    startTimer()
                }
            }
        }
    }
    
    // MARK: - Cardio Timer Logic
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !isPaused {
                timeElapsed += 1
                calories = Int(timeElapsed / 15)
                distance = Double(timeElapsed) / 600.0
                bpm = 90 + Int(timeElapsed.truncatingRemainder(dividingBy: 30))
            }
        }
    }
}

#Preview {
    NavigationStack {
        CountdownCardioView()
            .environmentObject(Router())
    }
}

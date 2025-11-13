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
                    StatCardItem(
                        icon: "flame.fill",
                        value: "\(calories)",
                        label: "KCAL"
                    )
                    StatCardItem(
                        icon: "figure.walk",
                        value: String(format: "%.1f", distance),
                        label: "KILOMETERS"
                    )
                    StatCardItem(
                        icon: "heart.fill",
                        value: "\(bpm)",
                        label: "BPM"
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
                
                Spacer()
                
                // MARK: - Button
                PrimaryGlassButton(title: connectivity.isWorkoutPaused ? "Resume" : "Pause") {
                    if connectivity.isWorkoutPaused {
                        connectivity.resumeWorkoutFromPhone()
                        showPausePopup = false
                    } else {
                        connectivity.pauseWorkoutFromPhone()
                        showPausePopup = true
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .blur(radius: showPausePopup ? 3 : 0)
            .disabled(showPausePopup)
            
            if showPausePopup {
                WorkoutPausePopup(
                    characterImage: "buttercup",
                    onResume: {
                        showPausePopup = false
                        connectivity.resumeWorkoutFromPhone()
                    },
                    onEndWorkout: {
                        timer?.invalidate()
                        connectivity.stopWorkoutFromPhone()
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
            //print("connectivity \(connectivity.isWorkoutActive)")
            startTimer()
        }
        .onDisappear { timer?.invalidate() }
        .onChange(of: connectivity.isWorkoutActive) { _, active in
            print("onchange isWorkoutActive: \(connectivity.isWorkoutActive)")
            if !active && !connectivity.isWorkoutPaused {
                print(
                    "🏁 Workout stopped from watch → showing FinishWorkoutView"
                )
                router.navigateTo(.finishWorkout)
            }
        }
        .onChange(of: connectivity.isWorkoutPaused) { _, paused in
            if paused {
                // Pause from WATCH → show popup
                print("⌚ Pause from watch → show popup")
                showPausePopup = true
            } else {
                showPausePopup = false
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
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            _ in
            guard !connectivity.isWorkoutPaused else { return }
            connectivity.timeActive += 1

            // UI update — tapi *tanpa kirim apa pun ke watch*
            timeElapsed = connectivity.timeActive
            calories = Int(connectivity.energyBurned)
            distance = connectivity.distance / 1000
            bpm = Int(connectivity.heartRate)
        }
    }
}

// MARK: - Reusable Pause Popup
struct WorkoutPausePopup: View {
    let characterImage: String
    var onResume: () -> Void
    var onEndWorkout: () -> Void

    @Environment(iPhoneConnectivityManager.self) private var connectivity

    var body: some View {
        ZStack {
            // Background gelap transparan
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onResume() }

            VStack(spacing: 0) {
                ZStack(alignment: .top) {

                    // MARK: - Kotak Putih
                    VStack(spacing: 14) {
                        Spacer().frame(height: 50)  // ruang untuk karakter di atas

                        PrimaryGlassButton(title: "Resume") {
                            onResume()
                            connectivity.resumeWorkoutFromPhone()
                        }

                        NeutralGlassButton(title: "End Workout") {
                            onEndWorkout()
                            connectivity.stopWorkoutFromPhone()
                        }
                        Spacer().frame(height: 10)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(
                                color: .black.opacity(0.15),
                                radius: 15,
                                x: 0,
                                y: 8
                            )

                    )

                    // MARK: - Karakter setengah badan di atas kotak
                    Image(characterImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .offset(y: -65)  // setengah badannya nongol di atas kotak
                }
            }
            .padding(.horizontal, 40)
            .transition(.scale.combined(with: .opacity))
        }
        .transition(.scale.combined(with: .opacity))
    }
}

// #Preview {
//     NavigationStack {
//         StartCardioView()
//             .environmentObject(Router())
//     }
// }

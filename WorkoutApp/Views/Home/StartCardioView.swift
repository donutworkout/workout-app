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
    private let phoneConnectivity = iPhoneConnectivityManager.shared
    
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
            
            // MARK: - Button
            PrimaryGlassButton(title: isPaused ? "Resume" : "Pause") {
                if isPaused {
                    // ✅ Resume workout
                    phoneConnectivity.resumeWorkoutFromPhone()
                } else {
                    // ✅ Pause workout
                    phoneConnectivity.pauseWorkoutFromPhone()
                }
                isPaused.toggle()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal)
            .padding(.bottom, 40)
            .blur(radius: showPausePopup ? 3 : 0)
            .disabled(showPausePopup)
            
            // MARK: - Pause Popup
            if showPausePopup {
                WorkoutPausePopup(
                    characterImage: "buttercup",
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
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle(activityName)
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
        .onAppear { startTimer() }
        .onDisappear { timer?.invalidate() }
    }

    
    private var formattedTime: String {
        let hours = Int(timeElapsed) / 3600
        let minutes = (Int(timeElapsed) % 3600) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
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

// MARK: - Reusable Pause Popup
struct WorkoutPausePopup: View {
    let characterImage: String
    var onResume: () -> Void
    var onEndWorkout: () -> Void

    var body: some View {
        ZStack {
            // Background gelap transparan
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onResume() }

            VStack {
                ZStack(alignment: .top) {
                    // MARK: - Character (lebih kecil, di atas box, tidak menimpa)
                    Image(characterImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .zIndex(2)
                        .padding(.top, -80)
//                    Spacer()

                    // MARK: - Kotak putih besar di bawah karakter
                    VStack(spacing: 18) {
                        Spacer()

                        PrimaryGlassButton(title: "Resume") {
                            onResume()
                        }
                        .frame(width: 320)

                        NeutralGlassButton(title: "End Workout") {
                            onEndWorkout()
                        }
                        .frame(width: 320)

                        Spacer().frame(height: 20)
                    }
                    .frame(width: 380, height: 240)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                    )
                    .zIndex(1)
                }
            }
        }
        .transition(.scale.combined(with: .opacity))
    }
}




#Preview {
    NavigationStack {
        StartCardioView()
            .environmentObject(Router())
    }
}


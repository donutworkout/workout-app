//
//  StartCardioView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 27/10/25.
//

import SwiftUI
import SwiftData

struct StartCardioView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    @Environment(iPhoneConnectivityManager.self) private var connectivity
    
    @Query private var userProfiles: [UserProfile]
    
    // MARK: - Props
    var activityName: String = "Badminton"
    var imageName: String = "charBadminton"
    
    @State private var timeElapsed: TimeInterval = 0
    @State private var calories: Int = 0
    @State private var distance: Double = 0.0
    @State private var bpm: Int = 90
    @State private var showPausePopup: Bool = false
    @State private var showHRAlert: Bool = false
    @State private var hasReachedGoal = false
    
    @State private var timer: Timer? = nil
    
    let selectedIntensity: IntensityLevel  // e.g. .vigorous or .moderate
    let vigorousDuration: Int
    let moderateDuration: Int

    var durationGoal: Int {
        selectedIntensity == .vigorous ? vigorousDuration : moderateDuration
    }
    
    var durationGoalSeconds: TimeInterval {
        TimeInterval(durationGoal * 60)
    }
    
    private var userProfile: UserProfile? {
        userProfiles.first
    }
    
    // MARK: - Check if activity should show distance
    private var shouldShowDistance: Bool {
        let distanceActivities = ["Outdoor Run", "Indoor Run", "Outdoor Walk", "Indoor Walk",
                                  "Cycling", "Swimming"]
        return distanceActivities.contains(activityName)
    }

    private var isSwimming: Bool {
        return activityName == "Swimming"
    }

    private var distanceValue: String {
        if isSwimming {
            // Swimming: show in meters
            return String(format: "%.0f", distance * 1000)
        } else {
            // Other activities: show in kilometers
            return String(format: "%.2f", distance)
        }
    }

    private var distanceLabel: String {
        return isSwimming ? "METERS" : "KILOMETERS"
    }
    
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
                
                // MARK: - Stats (Conditional Layout)
                HStack(spacing: 12) {
                    StatCardItem(
                        icon: "flame.fill",
                        value: "\(calories)",
                        label: "KCAL"
                    )
                    
                    // Only show distance for specific activities
                    if shouldShowDistance {
                        StatCardItem(
                            icon: isSwimming ? "figure.pool.swim" : "figure.walk",
                            value: distanceValue,
                            label: distanceLabel
                        )
                    }
                    
                    StatCardItem(
                        icon: "heart.fill",
                        value: connectivity.heartRate > 0 ? "\(bpm)" : "--",
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
                Alert(
                    characterImage: "",
                    onResume: {
                        showPausePopup = false
                        connectivity.resumeWorkoutFromPhone()
                    },
                    onEndWorkout: {
                        timer?.invalidate()
                        connectivity.stopWorkoutFromPhone()
                        
                        if hasReachedGoal {
                            router.navigateTo(.finishWorkout)
                        } else {
                            router.navigateTo(.halfwayWorkout)
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
            }
            
            if showHRAlert {
                ZStack {
                    // ✅ Full screen overlay
                    Color.white.opacity(0.5)
                        .ignoresSafeArea(.all) // ✅ Cover everything including safe areas
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showHRAlert = false
                                connectivity.isWorkoutPaused = false
                            }
                        }
                    
                    // ✅ Alert Dialog
                    VStack(spacing: 0) {
                        // MARK: - Content Area
                        VStack(spacing: 12) {
                            // Title
                            Text("Maximum HR Reached")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            // Message
                            Text("You've reached your max HR, please slow down:)")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        
                        Divider()
                        
                        // MARK: - Button
                        Button(action: {
                            withAnimation(.spring()) {
                                showHRAlert = false
                                connectivity.isWorkoutPaused = false
                            }
                        }) {
                            Text("OK")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color("pinkTextPrimary"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .contentShape(Rectangle())
                        }
                    }
                    .frame(width: 270)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                }
                .transition(.opacity.combined(with: .scale(scale: 1.1)))
                .zIndex(999) // ✅ Ensure it's on top
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
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            startTimer()
            print("workout goal: \(durationGoal), \(durationGoalSeconds)")
        }
        .onDisappear { timer?.invalidate() }
        .onChange(of: connectivity.isWorkoutActive) { _, active in
            print("onchange isWorkoutActive: \(connectivity.isWorkoutActive)")
            if !active && !connectivity.isWorkoutPaused {
                print(
                    "🏁 Workout stopped from watch → showing FinishWorkoutView"
                )
                
                if hasReachedGoal {
                    router.navigateTo(.finishWorkout)
                } else {
                    // Navigate to another view if goal not reached
                    router.navigateTo(.halfwayWorkout)
                }
            }
        }
        .onChange(of: connectivity.isWorkoutPaused) { _, paused in
            if paused {
                print("⌚ Pause from watch → show popup")
                showPausePopup = true
            } else {
                showPausePopup = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .startLocalTimer)) { _ in
            timeElapsed = 0
            startTimer()
        }

        .onReceive(NotificationCenter.default.publisher(for: .pauseLocalTimer)) { _ in
            timer?.invalidate()
        }

        .onReceive(NotificationCenter.default.publisher(for: .resumeLocalTimer)) { _ in
            startTimer()
        }

    }
    
    private var formattedTime: String {
        let total = Int(timeElapsed)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !connectivity.isWorkoutPaused {
                timeElapsed += 1    // ⬅️ TIMER LOKAL
            }
            calories = Int(connectivity.energyBurned)
            distance = connectivity.distance / 1000
            bpm = connectivity.heartRate > 0 ? Int(connectivity.heartRate) : 0
                                                                            
            if countMaximumHR() && !showHRAlert {
                showHRAlert = true
            }
            
            if !hasReachedGoal && timeElapsed >= durationGoalSeconds {
                hasReachedGoal = true
            }

        }
    }
    
    private func countMaximumHR() -> Bool {
        let age = Double(userProfile?.age ?? 0)
        let maxHR = Int(208.0 - (0.7 * age))
        return bpm >= maxHR
    }
}


extension Notification.Name {
    static let startLocalTimer = Notification.Name("startLocalTimer")
    static let pauseLocalTimer = Notification.Name("pauseLocalTimer")
    static let resumeLocalTimer = Notification.Name("resumeLocalTimer")
}

enum IntensityLevel: CaseIterable {
    case moderate
    case vigorous
}

// #Preview {
//     NavigationStack {
//         StartCardioView()
//             .environmentObject(Router())
//     }
// }


//
//  AdjustMenuStrengthView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 24/10/25.
//

import SwiftUI
import HealthKit

struct AdjustMenuStrengthView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMenu: StrengthMenuType = .bodyweight
    @EnvironmentObject var router: Router
    var onNext: (() -> Void)? = nil

    // Workout data
    let bodyweightWorkouts: [WorkoutItem] = [
        WorkoutItem(image: "gluteBridge", name: "Glute Bridge", sets: 2, reps: "30 sec"),
        WorkoutItem(image: "plankRow", name: "Plank Row", sets: 3, reps: "30 sec"),
        WorkoutItem(image: "deadBug", name: "Dead Bug", sets: 1, reps: "12"),
        WorkoutItem(image: "childPose", name: "Child Pose", sets: 1, reps: "12")
    ]
    
    let gymWorkouts: [WorkoutItem] = [
        WorkoutItem(image: "childPose", name: "Leg Press", sets: 3, reps: "10"),
        WorkoutItem(image: "deadBug", name: "Lat Pulldown", sets: 3, reps: "8"),
        WorkoutItem(image: "plankRow", name: "Cable Curl", sets: 3, reps: "12"),
        WorkoutItem(image: "gluteBridge", name: "Shoulder Press", sets: 3, reps: "10")
    ]
    
    init() {
        // Warna segmented control kustom (pink)
        let pinkColor = UIColor(named: "pinkTextPrimary") ?? UIColor.systemPink
        let selectedAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        let normalAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
        let appearance = UISegmentedControl.appearance()
        appearance.selectedSegmentTintColor = pinkColor
        appearance.setTitleTextAttributes(selectedAttrs, for: .selected)
        appearance.setTitleTextAttributes(normalAttrs, for: .normal)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // MARK: - Segmented Control
                Picker("Menu Type", selection: $selectedMenu) {
                    ForEach(StrengthMenuType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                .onChange(of: selectedMenu) { _, newValue in
                    let workoutType: HKWorkoutActivityType
                    switch newValue {
                    case .bodyweight:
                        workoutType = .functionalStrengthTraining
                    case .gym:
                        workoutType = .traditionalStrengthTraining
                    }
                    router.selectedWorkoutType = workoutType
                    iPhoneConnectivityManager.shared.sendSelectedWorkout(workoutType)
                }

                // MARK: - Workout Cards
                VStack(spacing: 16) {
                    if selectedMenu == .bodyweight {
                        ForEach(bodyweightWorkouts) { workout in
                            WorkoutItemCard(workout: workout)
                        }
                    } else {
                        Text("Do your own gym routine! :)")
                        
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24) // extra space so last card isn't obscured by bottom button
            }
        }
        .safeAreaInset(edge: .bottom) {
            // MARK: - Bottom anchored button
            VStack {
                PrimaryGlassButton(title: "Start Now") {
                    router.lastWorkoutSource = .adjustMenuStrength
                    router.navigateTo(.countdownView)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .background(Color.white.opacity(0.95))
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Today’s Strength Menu!")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    router.navigateTo(.menu) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
    }
}

// MARK: - Enums & Models
enum StrengthMenuType: String, CaseIterable {
    case bodyweight = "Bodyweight"
    case gym = "Gym"
}

struct WorkoutItem: Identifiable {
    var id = UUID()
    var image: String
    var name: String
    var sets: Int
    var reps: String
}

#Preview {
    NavigationStack {
        AdjustMenuStrengthView()
    }
}

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
    var onNext: () -> Void = {}

    // Workout data
    let bodyweightWorkouts: [WorkoutItem] = [
        WorkoutItem(image: "bridge", name: "Bridge", sets: 2, reps: "30 sec"),
        WorkoutItem(image: "plank", name: "Plank", sets: 3, reps: "30 sec"),
        WorkoutItem(image: "kneeTap", name: "Knee Tap", sets: 1, reps: "12"),
        WorkoutItem(image: "catCow", name: "Cat and Cow", sets: 1, reps: "12")
    ]
    
    let gymWorkouts: [WorkoutItem] = [
        WorkoutItem(image: "catCow", name: "Leg Press", sets: 3, reps: "10"),
        WorkoutItem(image: "kneeTap", name: "Lat Pulldown", sets: 3, reps: "8"),
        WorkoutItem(image: "plank", name: "Cable Curl", sets: 3, reps: "12"),
        WorkoutItem(image: "bridge", name: "Shoulder Press", sets: 3, reps: "10")
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
                    iPhoneConnectivityManager.shared.sendSelectedWorkout(workoutType)
                }
                
                // MARK: - Workout Cards
                VStack(spacing: 16) {
                    ForEach(selectedMenu == .bodyweight ? bodyweightWorkouts : gymWorkouts) { workout in
                        WorkoutItemCard(workout: workout)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // MARK: - Start Button
                PrimaryGlassButton(title: "Start Now") {
                    onNext() // ✅ panggil router.navigateTo() nanti di RouterView
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Today’s Strength Menu!")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
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

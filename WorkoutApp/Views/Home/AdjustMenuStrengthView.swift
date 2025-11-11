//
//  AdjustMenuStrengthView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 24/10/25.
//

import SwiftUI
import HealthKit
import SwiftData

struct AdjustMenuStrengthView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedMenu: StrengthMenuType = .bodyweight
    @State private var workouts: [Exercise] = []

    @EnvironmentObject var router: Router
    
    @Query private var userCycles: [UserCycle]
    @Query private var userProfiles: [UserProfile]
    @Query private var userWorkouts: [UserWorkout]
    
    private let sessionManager = StrengthSessionManager.shared
    
    var onNext: (() -> Void)? = nil
    
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
                        ForEach(workouts) { workout in
                            WorkoutItemCard(workout: workout)
                        }
                    } else {
                        Spacer()
                        
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
                    
                    sessionManager.startWorkout(with: workouts)
                
                    router.workoutExercises = workouts

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
        .onAppear {
            DummyExerciseProvider.shared.clearAllExercises(from: modelContext)
            DummyExerciseProvider.shared.insertDummyData(into: modelContext)
            
            loadBodyWeightExercises()
        }
        .environmentObject(sessionManager)
    }
    
    private func loadBodyWeightExercises() {
        guard let cycle = userCycle, let profile = userWorkout else { return }
        
        let repo = ExerciseRepository(context: modelContext)
        let generator = WorkoutMenuGenerator(context: modelContext)
        let level = profile.workoutLevel
        
        let currentPhase = CyclePhaseCalculator.calculateCurrentPhase(
            lastPeriodStart: cycle.cycleStartDate,
            menstrualDuration: cycle.menstrualDuration
        )
        
        let specs = generator.getStrengthSpecs(for: level, phase: currentPhase)
        
        // Fetch exercises
        var exercises = repo.getExercises(
            forLevel: level,
            phase: currentPhase,
            count: 5
        )
        
        // Apply sets and reps to each exercise
        for i in 0..<exercises.count {
            exercises[i].sets = specs.sets
            exercises[i].reps = specs.reps
        }
        
        workouts = exercises
    }
}

// MARK: - Enums & Models
enum StrengthMenuType: String, CaseIterable {
    case bodyweight = "Bodyweight"
    case gym = "Gym"
}

//struct WorkoutItem: Identifiable {
//    var id = UUID()
//    var image: String
//    var name: String
//    var sets: Int
//    var reps: String
//}

extension AdjustMenuStrengthView {
    private var userCycle: UserCycle? {
        userCycles.first
    }
    
    private var userProfile: UserProfile? {
        userProfiles.first
    }
    
    private var userWorkout: UserWorkout? {
        userWorkouts.first
    }
}

#Preview {
    NavigationStack {
        AdjustMenuStrengthView()
    }
}

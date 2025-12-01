//
//  AdjustMenuStrengthView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 24/10/25.
//

import HealthKit
import SwiftData
import SwiftUI

struct AdjustMenuStrengthView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(iPhoneConnectivityManager.self) private var connectivity

    @State private var workouts: [Exercise] = []

    @EnvironmentObject var router: Router

    @Query private var userCycles: [UserCycle]
    @Query private var userProfiles: [UserProfile]
    @Query private var userWorkouts: [UserWorkout]

    private let sessionManager = StrengthSessionManager.shared
    let dailyMenu: DailyMenu?

    @State var workoutType: HKWorkoutActivityType = .functionalStrengthTraining

    var onNext: (() -> Void)? = nil

    init(dailyMenu: DailyMenu? = nil) {
        self.dailyMenu = dailyMenu
    }
    
    private var isToday: Bool {
        guard let menuDate = dailyMenu?.date else { return false }
        return Calendar.current.isDateInToday(menuDate)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // MARK: - Workout Cards
                VStack(spacing: 16) {
                    ForEach(Array(workouts.enumerated()), id: \.element) { index, workout in
                        WorkoutItemCard(workout: workout)
                            .pageCardAnimation(delay: 0.2 + Double(index) * 0.1)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                PrimaryGlassButton(
                    title: isToday ? "Start Now" : "Not Available Today",
                    isDisabled: !isToday
                ) {
                    sessionManager.prepareWorkout(with: workouts)
                    router.workoutExercises = workouts

                    let mapping = mapActivityToHKType("bodyweight")
                    router.selectedWorkoutType = mapping.type

                    iPhoneConnectivityManager.shared.sendSelectedWorkout(
                        mapping.type,
                        activityName: "Bodyweight",
                        isIndoor: mapping.isIndoor
                    )

                    iPhoneConnectivityManager.shared.startWorkoutFromPhone(
                        type: mapping.type,
                        isIndoor: mapping.isIndoor
                    )

                    router.lastWorkoutSource = .adjustMenuStrength
                    router.navigateTo(.countdownView)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .pageCardAnimation(delay: 0.3)
            }
            .background(Color.white.opacity(0.95))
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Today’s Strength Menu!")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    router.navigateTo(.menu)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            workoutType = .functionalStrengthTraining
            let mapping = mapActivityToHKType("bodyweight")
            connectivity.sendSelectedWorkout(
                mapping.type,
                activityName: "Bodyweight",
                isIndoor: mapping.isIndoor
            )
            
            Task {
                await DummyExerciseProvider.shared.insertDummyData(into: modelContext)
                loadBodyWeightExercises()
            }
        }
        .onChange(of: connectivity.isWorkoutActive) { _, active in
            if active {
                print("🏋️ Watch started workout → go to countdown/start")
                router.lastWorkoutSource = .adjustMenuStrength
                router.navigateTo(.countdownView)
            }

        }
    }

    private func loadBodyWeightExercises() {
        print("🔍 DEBUG: loadBodyWeightExercises called")
        print("🔍 dailyMenu exists: \(dailyMenu != nil)")
        
        if let menu = dailyMenu {
            print("🔍 dailyMenu.strengthExercises exists: \(menu.strengthExercises != nil)")
            print("🔍 dailyMenu.strengthExercises count: \(menu.strengthExercises?.count ?? 0)")
            print("🔍 dailyMenu.strengthExercises isEmpty: \(menu.strengthExercises?.isEmpty ?? true)")
        }
        
        if let menu = dailyMenu, let savedExercises = menu.strengthExercises, !savedExercises.isEmpty {
            print("✅ Loading \(savedExercises.count) saved exercises from DailyMenu")
            workouts = savedExercises
            return
        }
        
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
        let exercises = repo.getExercises(
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
        
        if let menu = dailyMenu {
            menu.strengthExercises = exercises
            try? modelContext.save()
            print("💾 Saved \(exercises.count) exercises to DailyMenu")
        }
    }
}

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

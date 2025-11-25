//
//  EditWorkoutLevelView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 09/11/25.
//

import SwiftUI
import SwiftData

struct EditWorkoutLevelView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \UserProfile.createdAt, order: .reverse)
    private var profiles: [UserProfile]
    
    private var currentProfile: UserProfile? {
        profiles.first
    }
    
    // MARK: - States
    @State private var selectedFrequency: String? = nil
    @State private var selectedDuration: String? = nil
    @State private var selectedIntensity: String? = nil
    @State private var selectedExperience: String? = nil
    @State private var showSaveAlert = false
    
    // MARK: - Options
    let workoutFrequency = WorkoutTimesAWeek.allCases.map { $0.displayName }
    let workoutDuration = WorkoutDuration.allCases.map { $0.displayName }
    let workoutIntensity = WorkoutIntensity.allCases.map { $0.displayName }
    let workoutExperience = WorkoutExperience.allCases.map { $0.displayName }
    
    var hasChanges: Bool {
        selectedFrequency != nil && selectedDuration != nil &&
        selectedIntensity != nil && selectedExperience != nil
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header (anchored)
            HeaderButton(
                title: "Workout Level",
                isEditing: hasChanges,
                onClose: { dismiss() },
                onEditToggle: {
                    if hasChanges {
                        saveWorkoutPreferences()
                    }
                }
            )
            .padding(.horizontal)
            .padding(.top, 0)

            // MARK: - Scrollable Content
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: - Title & Character
                    VStack(spacing: 16) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tell us about your\nworkout routine")
                                    .font(.system(.title, weight: .semibold))
                                    .foregroundColor(Color("pinkTextPrimary"))
                            }
                            Spacer()
                            Image("characterSurvey")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)

                    // MARK: - Sections
                    VStack(spacing: 24) {
                        // Frequency
                        EditWorkoutSection(
                            title: "How often a week?",
                            subtitle: "Your usual workout frequency",
                            options: workoutFrequency,
                            selectedOption: $selectedFrequency
                        )

                        // Duration
                        EditWorkoutSection(
                            title: "How long per session?",
                            subtitle: "Your typical workout duration",
                            options: workoutDuration,
                            selectedOption: $selectedDuration
                        )

                        // Intensity
                        EditWorkoutSection(
                            title: "How intense are your workouts?",
                            subtitle: "Your usual workout effort",
                            options: workoutIntensity,
                            selectedOption: $selectedIntensity
                        )

                        // Experience
                        EditWorkoutSection(
                            title: "How long have you workout?",
                            subtitle: "Your overall experience level",
                            options: workoutExperience,
                            selectedOption: $selectedExperience
                        )
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 0)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadWorkoutData()
        }
        .alert("Preferences Updated", isPresented: $showSaveAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your workout preferences have been successfully updated.")
        }
    }
    
    // MARK: - Backend Functions
    
    private func loadWorkoutData() {
        guard let profile = currentProfile,
              let workout = profile.userWorkouts?.first else {
            print("⚠️ No workout data found")
            return
        }
        
        selectedFrequency = workout.workoutTimesAWeek?.displayName
        selectedDuration = workout.workoutDuration?.displayName
        selectedIntensity = workout.workoutIntensity?.displayName
        selectedExperience = workout.workoutExperience?.displayName
        
        print("✅ Workout data loaded")
    }
    
    private func saveWorkoutPreferences() {
        guard let profile = currentProfile else {
            print("❌ Cannot save: No profile found")
            return
        }
        
        // Get or create workout
        let workout: UserWorkout
        if let existingWorkout = profile.userWorkouts?.first {
            workout = existingWorkout
        } else {
            workout = UserWorkout(
                workoutMotivation: .keepFit,
                workoutTimesAWeek: .twoToThreeTimes,
                workoutDuration: .thirtyToSixtyMinutes,
                workoutIntensity: .moderate,
                workoutExperience: .underOneMonth,
                workoutLevel: .beginner,
                workoutDaysPreference: []
            )
            profile.userWorkouts = [workout]
        }
        
        // Update workout preferences
        if let frequency = selectedFrequency,
           let freq = WorkoutTimesAWeek.allCases.first(where: { $0.displayName == frequency }) {
            workout.workoutTimesAWeek = freq
        }
        
        if let duration = selectedDuration,
           let dur = WorkoutDuration.allCases.first(where: { $0.displayName == duration }) {
            workout.workoutDuration = dur
        }
        
        if let intensity = selectedIntensity,
           let intens = WorkoutIntensity.allCases.first(where: { $0.displayName == intensity }) {
            workout.workoutIntensity = intens
        }
        
        if let experience = selectedExperience,
           let exp = WorkoutExperience.allCases.first(where: { $0.displayName == experience }) {
            workout.workoutExperience = exp
        }
        
        do {
            try modelContext.save()
            print("✅ Workout preferences saved successfully")
            showSaveAlert = true
        } catch {
            print("❌ Error saving: \(error.localizedDescription)")
        }
    }
}

// MARK: - Section Component
struct EditWorkoutSection: View {
    let title: String
    let subtitle: String
    let options: [String]
    @Binding var selectedOption: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)
            
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    SelectableButton(
                        title: option,
                        isSelected: selectedOption == option
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedOption = option
                        }
                    }
                }
            }
            .padding(16)
            .glassEffect(in: .rect(cornerRadius: 25.0))
        }
    }
}

#Preview {
    NavigationStack {
        EditWorkoutLevelView()
            .modelContainer(for: [UserProfile.self, UserWorkout.self, UserCycle.self])
    }
}

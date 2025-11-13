//
//  EditWorkoutLevelView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 09/11/25.
//

import SwiftUI

struct EditWorkoutLevelView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var surveyManager: SurveyManager
    
    // MARK: - States
    @State private var selectedFrequency: String? = nil
    @State private var selectedDuration: String? = nil
    @State private var selectedIntensity: String? = nil
    @State private var selectedExperience: String? = nil
    
    // MARK: - Options
    let workoutFrequency = WorkoutTimesAWeek.allCases.map { $0.displayName }
    let workoutDuration = WorkoutDuration.allCases.map { $0.displayName }
    let workoutIntensity = WorkoutIntensity.allCases.map { $0.displayName }
    let workoutExperience = WorkoutExperience.allCases.map { $0.displayName }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header (anchored)
            HeaderButton(
                title: "Workout Level",
                isEditing: true,
                onClose: { dismiss() },
                onEditToggle: { dismiss() }
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
            // Initialize from SurveyManager
            selectedFrequency = surveyManager.tempWorkoutTimesAWeek.displayName
            selectedDuration = surveyManager.tempWorkoutDuration.displayName
            selectedIntensity = surveyManager.tempWorkoutIntensity.displayName
            selectedExperience = surveyManager.tempWorkoutExperience.displayName
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

//#Preview {
//    NavigationStack {
//        EditWorkoutLevelView()
//            .environmentObject(SurveyManager())
//    }
//}

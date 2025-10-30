//
//  SurveyWorkoutLevelView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 23/10/25.
//

import SwiftUI

struct SurveyWorkoutLevelView: View {
    @EnvironmentObject var surveyManager: SurveyManager
    
    var onNext: () -> Void
    
    // MARK: - States
    @State private var selectedFrequency: [String] = []
    @State private var selectedDuration: [String] = []
    @State private var selectedIntensity: [String] = []
    @State private var selectedExperience: [String] = []
    
    // MARK: - Options
    let workoutFrequency = WorkoutTimesAWeek.allCases.map { $0.displayName }
    let workoutDuration = WorkoutDuration.allCases.map { $0.displayName }
    let workoutIntensity = WorkoutIntensity.allCases.map { $0.displayName }
    let workoutExperience = WorkoutExperience.allCases.map { $0.displayName }
    
    private func frequencyFromDisplayName(_ name: String) -> WorkoutTimesAWeek? {
        WorkoutTimesAWeek.allCases.first { $0.displayName == name }
    }
    
    private func durationFromDisplayName(_ name: String) -> WorkoutDuration? {
        WorkoutDuration.allCases.first { $0.displayName == name }
    }
    
    private func intensityFromDisplayName(_ name: String) -> WorkoutIntensity? {
        WorkoutIntensity.allCases.first { $0.displayName == name }
    }
    
    private func experienceFromDisplayName(_ name: String) -> WorkoutExperience? {
        WorkoutExperience.allCases.first { $0.displayName == name }
    }
    
    // MARK: - Computed Property
    var isAllAnswered: Bool {
        !selectedFrequency.isEmpty &&
        !selectedDuration.isEmpty &&
        !selectedIntensity.isEmpty &&
        !selectedExperience.isEmpty
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // MARK: - Header
//                    Text("Survey")
//                        .font(.headline)
//                        .foregroundColor(.black)
//                        .padding(.top, 20)
                    
                    // MARK: - Title & Character
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            SurveyProgressText(currentPage: 4, totalPages: 6)
                            Text("Workout\nLevel")
                                .font(.system(.title, weight: .semibold))
                                .foregroundColor(Color("pinkTextPrimary"))
                        }
                        Spacer()
                        Image("characterSurvey")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // MARK: - Question Sections
                    Group {
                        SurveySection(
                            title: "How often a week?",
                            subtitle: "Your usual workout frequency",
                            options: workoutFrequency,
                            selectedOptions: $selectedFrequency,
                            allowsMultipleSelection: false
                        )
                        
                        SurveySection(
                            title: "How long per session?",
                            subtitle: "Your typical workout duration",
                            options: workoutDuration,
                            selectedOptions: $selectedDuration,
                            allowsMultipleSelection: false
                        )
                        
                        SurveySection(
                            title: "How intense are your workouts?",
                            subtitle: "Your usual workout effort",
                            options: workoutIntensity,
                            selectedOptions: $selectedIntensity,
                            allowsMultipleSelection: false
                        )
                        
                        SurveySection(
                            title: "How long have you workout?",
                            subtitle: "Your overall experience level",
                            options: workoutExperience,
                            selectedOptions: $selectedExperience,
                            allowsMultipleSelection: false
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 100)
            }
            
            // MARK: - Next Button
            PrimaryGlassButton(title: "Next", action: saveAndNext)
                .padding(.horizontal)
                .padding(.vertical)
                .disabled(!isAllAnswered)
                .opacity(isAllAnswered ? 1 : 0.5)
            
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            // Initialize selections from surveyManager, converting to display-name arrays
            selectedFrequency = [surveyManager.tempWorkoutTimesAWeek.displayName]
            selectedDuration = [surveyManager.tempWorkoutDuration.displayName]
            selectedIntensity = [surveyManager.tempWorkoutIntensity.displayName]
            selectedExperience = [surveyManager.tempWorkoutExperience.displayName]
        }
    }
}

extension SurveyWorkoutLevelView {
    private func saveAndNext() {
        if let freqString = selectedFrequency.first,
           let frequency = frequencyFromDisplayName(freqString) {
            surveyManager.updateTempWorkoutTimesAWeek(frequency)
            print("✅ Frequency saved: \(frequency.rawValue)")
        }
                
        if let durationString = selectedDuration.first,
           let duration = durationFromDisplayName(durationString) {
            surveyManager.updateTempWorkoutDuration(duration)
            print("✅ Duration saved: \(duration.rawValue)")
        }
                
        if let intensityString = selectedIntensity.first,
           let intensity = intensityFromDisplayName(intensityString) {
            surveyManager.updateTempWorkoutIntensity(intensity)
            print("✅ Intensity saved: \(intensity.rawValue) - Display: \(intensity.displayName)")
        }
                
        if let experienceString = selectedExperience.first,
           let experience = experienceFromDisplayName(experienceString) {
            surveyManager.updateTempWorkoutExperience(experience)
            print("✅ Experience saved: \(experience.rawValue) - Display: \(experience.displayName)")
        }
        
        surveyManager.updateTempWorkoutLevel()
        onNext()
    }
}

#Preview {
    SurveyWorkoutLevelView(onNext: {})
}

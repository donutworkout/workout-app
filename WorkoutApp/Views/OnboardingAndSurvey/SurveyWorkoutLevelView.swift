//
//  SurveyWorkoutLevelView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 23/10/25.
//

import SwiftUI

struct SurveyWorkoutLevelView: View {
    var onNext: () -> Void
    
    // MARK: - States
    @State private var selectedFrequency: [String] = []
    @State private var selectedDuration: [String] = []
    @State private var selectedIntensity: [String] = []
    @State private var selectedExperience: [String] = []
    
    // MARK: - Options
    let workoutFrequency = ["2–3x", "4–5x", "Everyday"]
    let workoutDuration = ["< 30 min", "30–60 min", "> 60 min"]
    let workoutIntensity = [
        "Light (you can still chat easily)",
        "Moderate (a bit sweaty)",
        "Hard (sweating a lot, can’t really talk)",
        "Super intense (pushing your max)"
    ]
    let workoutExperience = [
        "Newbie (<1 month)",
        "1–3 month",
        "4–6 month",
        "> 6 month"
    ]
    
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
                    Text("Survey")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top, 20)
                    
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
            PrimaryGlassButton(title: "Next", action: onNext)
                .padding(.horizontal)
                .padding(.vertical)
                .disabled(!isAllAnswered)
                .opacity(isAllAnswered ? 1 : 0.5)
            
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    SurveyWorkoutLevelView(onNext: {})
}

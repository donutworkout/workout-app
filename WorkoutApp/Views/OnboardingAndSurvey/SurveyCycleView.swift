//
//  SurveyCycleView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI

struct SurveyCycleView: View {
    var onFinish: () -> Void
    
    // MARK: - States
    @State private var selectedMenstrualCycle: [String] = []
    @State private var selectedPhysicalSymptoms: [String] = []
    @State private var selectedEnergyLevel: [String] = []
    @State private var selectedMoodChanges: [String] = []
    
    // MARK: - Options
    let menstrualCycle = ["Yes", "No"]
    let physicalSymptoms = ["Cramps", "Back Pain", "Fatigue / Low Energy", "Mood Swing", "None of the above"]
    let energyLevel = ["I feel more energetic after my period", "Drops before/during period", "Stay stable"]
    let moodChanges = ["Often", "Sometime", "Never"]
    
    // MARK: - Computed property
    var isAllAnswered: Bool {
        !selectedMenstrualCycle.isEmpty &&
        !selectedPhysicalSymptoms.isEmpty &&
        !selectedEnergyLevel.isEmpty &&
        !selectedMoodChanges.isEmpty
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // MARK: - Header
                    Text("Survey")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top, 8)
                    
                    // MARK: - Title & Character
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What motivates\n you the most?")
                                .font(.system(.title, weight: .bold))
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
                        // Single select
                        SurveySection(
                            title: "Is your menstrual cycle regular?",
                            subtitle: "The variation of cycle length is less than 7 days",
                            options: menstrualCycle,
                            selectedOptions: $selectedMenstrualCycle,
                            allowsMultipleSelection: false
                        )
                        
                        // Multi select
                        SurveySection(
                            title: "What you feel when menstrual?",
                            subtitle: "Physical symptoms before or during",
                            options: physicalSymptoms,
                            selectedOptions: $selectedPhysicalSymptoms,
                            allowsMultipleSelection: true
                        )
                        
                        // Single select
                        SurveySection(
                            title: "How do your energy levels?",
                            subtitle: "Energy pattern during cycle",
                            options: energyLevel,
                            selectedOptions: $selectedEnergyLevel,
                            allowsMultipleSelection: false
                        )
                        
                        // Single select
                        SurveySection(
                            title: "Do mood changes affect workouts?",
                            subtitle: "It affects your motivation to exercise",
                            options: moodChanges,
                            selectedOptions: $selectedMoodChanges,
                            allowsMultipleSelection: false
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 100) // extra space for button
            }
            
            // MARK: - Finish Button
            Button(action: {
                if isAllAnswered {
                    onFinish()
                }
            }) {
                Text("Finish")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(isAllAnswered ? Color("pinkTextSecondary") : Color.gray.opacity(0.4))
                    )
                    .animation(.easeInOut(duration: 0.2), value: isAllAnswered)
            }
            .padding(.horizontal)
            .padding(.vertical)
            .disabled(!isAllAnswered)
        }
        .background(Color.white.ignoresSafeArea())
    }
}


#Preview {
    SurveyCycleView(onFinish: {})
}

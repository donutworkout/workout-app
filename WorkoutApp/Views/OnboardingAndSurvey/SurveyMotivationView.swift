//
//  SwiftUIView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI
import SwiftData

struct SurveyMotivationView: View {
    @EnvironmentObject var surveyManager: SurveyManager
    
    var onNext: () -> Void
    @State private var selectedMotivation: WorkoutMotivation? = nil
    
//    let motivations = ["Build Muscle", "Lose Weight", "Keep Fit"]
    
    private func saveAndNext() {
        if let motivation = selectedMotivation {
            surveyManager.updateTempWorkoutMotivation(motivation)
            print("✅ Motivation saved: \(motivation.rawValue)")
            onNext()
        }
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // MARK: - Header
//            Text("Survey")
//                .font(.headline)
//                .foregroundColor(.black)
//                .padding(.top, 20)
            
            // MARK: - Title & Character
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        SurveyProgressText(currentPage: 3, totalPages: 6)
                        Text("What motivates\n you the most?")
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
            
            // MARK: - Button Options
            VStack(spacing: 12) {
                ForEach(WorkoutMotivation.allCases, id: \.self) { goal in
                    SelectableButton(
                        title: goal.displayName,
                        isSelected: selectedMotivation == goal
                    ) {
                        // Single selection toggle
                        if selectedMotivation == goal {
                            selectedMotivation = nil // deselect
                        } else {
                            selectedMotivation = goal
                        }
                    }
                }
            }
            .padding(16)
            .glassEffect(in: .rect(cornerRadius: 25.0))
            .padding(.horizontal)
            
            Spacer()
            
            // MARK: - Next Button
            PrimaryGlassButton(title: "Next", action: saveAndNext)
                .padding(.horizontal)
                .padding(.vertical)
                .disabled(selectedMotivation == nil)
                .opacity(selectedMotivation == nil ? 0.5 : 1)
            
        }
        .onAppear {
            selectedMotivation = surveyManager.tempWorkoutMotivation
        }
    }
}

#Preview {
    SurveyMotivationView(onNext: {})
}

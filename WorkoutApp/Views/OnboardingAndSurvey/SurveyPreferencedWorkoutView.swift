//
//  SurveyPreferencedWorkoutView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI

struct SurveyPreferencedWorkoutView: View {
    var onNext: () -> Void
    @State private var selectedPreferedWorkout: String? = nil
    
    let preferedWorkout = ["Bodyweight", "Cardio", "Yoga"]
    
    var body: some View {
        VStack(spacing: 32) {
            // MARK: - Header
            Text("Survey")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.top, 8)
            
            // MARK: - Title & Character
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preferenced Workout")
                            .font(.system(.title, weight: .bold))
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
                ForEach(preferedWorkout, id: \.self) { goal in
                    SelectableButton(
                        title: goal,
                        isSelected: selectedPreferedWorkout == goal
                    ) {
                        // Single selection toggle
                        if selectedPreferedWorkout == goal {
                            selectedPreferedWorkout = nil // deselect
                        } else {
                            selectedPreferedWorkout = goal
                        }
                    }
                }
            }
            .padding(16)
            .glassEffect(in: .rect(cornerRadius: 25.0))
            .padding(.horizontal)
            
            Spacer()
            
            // MARK: - Next Button
            PrimaryGlassButton(title: "Next", action: onNext)
                .padding(.horizontal)
                .padding(.vertical)
                .disabled(selectedPreferedWorkout == nil) // disable kalau belum pilih
                .opacity(selectedPreferedWorkout == nil ? 0.5 : 1)
            
            PageControl(totalPages: 7, currentPage: 5)

        }
    }
}

#Preview {
    SurveyPreferencedWorkoutView(onNext: {})
}

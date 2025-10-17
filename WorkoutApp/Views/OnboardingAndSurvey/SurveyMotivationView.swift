//
//  SwiftUIView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI

struct SurveyMotivationView: View {
    var onNext: () -> Void
    @State private var selectedMotivation: String? = nil
    
    let motivations = ["Build Muscle", "Lose Weight", "Keep Fit"]
    
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
            }
            .padding(.top, 10)
            .padding(.horizontal)
            
            // MARK: - Button Options
            VStack(spacing: 12) {
                ForEach(motivations, id: \.self) { goal in
                    SelectableButton(
                        title: goal,
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
            PrimaryGlassButton(title: "Next", action: onNext)
                .padding(.horizontal)
                .padding(.vertical)
                .disabled(selectedMotivation == nil) // disable kalau belum pilih
                .opacity(selectedMotivation == nil ? 0.5 : 1) // efek visual disabled
        }
    }
}

#Preview {
    SurveyMotivationView(onNext: {})
}

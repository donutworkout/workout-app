//
//  EditMotivationView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 30/10/25.
//

import SwiftUI

struct EditMotivationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedMotivation: String? = nil
    
    private let motivations = [
        "Build Muscle",
        "Lose Weight",
        "Keep Fit",
        "Gain Energy",
        "Improve Mood"
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            
            // MARK: - Header (pakai HeaderButton)
            HeaderButton(
                title: "Motivation",
                isEditing: true,
                onClose: { dismiss() },
                onEditToggle: { dismiss() }
            )
            
            // MARK: - Title & Character
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What motivates you\nthe most?")
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
            
            // MARK: - Motivation Options
            VStack(spacing: 12) {
                ForEach(motivations, id: \.self) { goal in
                    SelectableButton(
                        title: goal,
                        isSelected: selectedMotivation == goal
                    ) {
                        if selectedMotivation == goal {
                            selectedMotivation = nil
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
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true) // ✅ Hilangkan back default
    }
}

#Preview {
    NavigationStack {
        EditMotivationView()
    }
}

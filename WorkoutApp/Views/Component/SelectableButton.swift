//
//  CustomSelectableButton.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI

struct SelectableButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .fill(isSelected ? Color("pinkTextSecondary") : Color.secondary.opacity(0.15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(isSelected ? Color("pinkTextSecondary") : Color.clear, lineWidth: 1)
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .glassEffect(.regular.interactive())
        .buttonStyle(.plain)
    }
}

struct MultiSelectableButtonView: View {
    @State private var selectedGoals: [String] = []
    
    let goals = ["Build Muscle", "Lose Weight", "Keep Fit", "Gain Strength", "Improve Flexibility"]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(goals, id: \.self) { goal in
                SelectableButton(
                    title: goal,
                    isSelected: selectedGoals.contains(goal)
                ) {
                    // Toggle selection logic
                    if selectedGoals.contains(goal) {
                        selectedGoals.removeAll { $0 == goal }
                    } else {
                        selectedGoals.append(goal)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    MultiSelectableButtonView()
}

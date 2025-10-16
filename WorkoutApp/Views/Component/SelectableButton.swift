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
                .foregroundColor(isSelected ? .white : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .fill(isSelected ? Color("pinkTextSecondary") : Color.secondary.opacity(0.3))
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 10) {
        SelectableButton(title: "Build Muscle", isSelected: true) {}
        SelectableButton(title: "Lose Weight", isSelected: false) {}
        SelectableButton(title: "Keep Fit", isSelected: false) {}
    }
    .padding()
}

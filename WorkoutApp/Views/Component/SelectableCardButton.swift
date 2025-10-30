//
//  SelectableCardButton.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 24/10/25.
//

import SwiftUI

struct SelectableCardButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .white : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color("pinkTextPrimary") : Color.white)
                        .shadow(color: .gray.opacity(0.15), radius: 4, x: 0, y: 2)
                )
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SelectableCardButton(title: "Cycling", isSelected: true, action: {})
        SelectableCardButton(title: "Swimming", isSelected: false, action: {})
    }
    .padding()
    .background(Color.white)
}

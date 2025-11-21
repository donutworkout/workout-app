//
//  PrimaryGlassButton.swift
//  WorkoutWacthApp Watch App
//
//  Created by Jennifer Evelyn on 05/11/25.
//

import SwiftUI

struct PrimaryGlassButton: View {
    var title: String
    var icon: String? = nil
    var action: () -> Void
    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
                action()
            }
        }) {
            ZStack {
                // Background with less rounded corners
                RoundedRectangle(cornerRadius: 100, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("pinkTextPrimary"),
                                Color("pinkTextPrimary")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 100, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                            .blendMode(.overlay)
                    )
                    .overlay(
                        LinearGradient(
                            colors: [
                                .white.opacity(isPressed ? 0.1 : 0.25),
                                .white.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                    )

                // Title with optional icon
                HStack(spacing: 6) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .opacity(isPressed ? 0.85 : 1.0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Text(title))
    }
}

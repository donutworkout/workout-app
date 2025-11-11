//
//  NeutralGlassButton.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 27/10/25.
//

import SwiftUI

struct NeutralGlassButton: View {
    var title: String
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
                // Background capsule (netral glass style)
                RoundedRectangle(cornerRadius: 100, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isPressed ? 0.85 : 0.95),
                                Color.white.opacity(isPressed ? 0.6 : 0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // Edge highlight
                        RoundedRectangle(cornerRadius: 100, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
                            .blendMode(.overlay)
                    )
                    .overlay(
                        // Top glossy light
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
                   
                // Title
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .opacity(isPressed ? 0.8 : 1.0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Text(title))
        .glassEffect(.regular.tint(.clear).interactive())
    }
}

#Preview {
    VStack(spacing: 24) {
        PrimaryGlassButton(title: "Start Workout") {}
        NeutralGlassButton(title: "End Workout") {}
        NeutralGlassButton(title: "Cancel") {}
    }
    .padding()
    .background(Color.white.ignoresSafeArea())
}

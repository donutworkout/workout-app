//
//  PrimaryButton.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI

struct PrimaryGlassButton: View {
    var title: String
    var action: () -> Void
    @State private var isPressed: Bool = false
    var isDisabled: Bool = false
    
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
                // Background capsule
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
                        // Top highlight gives clickable shine
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
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .opacity(isPressed ? 0.85 : 1.0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
        }
        .buttonStyle(.plain)
        
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Text(title))
        .glassEffect(.regular.tint(.clear).interactive())
        
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.7 : 1.0)
    }
}

#Preview {
    VStack(spacing: 24) {
        PrimaryGlassButton(title: "Start Now") {}
        PrimaryGlassButton(title: "Continue") {}
        PrimaryGlassButton(title: "End Workout") {}
    }
    .padding()
    .background(Color.white.ignoresSafeArea())
}

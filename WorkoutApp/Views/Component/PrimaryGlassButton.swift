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

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color("pinkTextSecondary"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color("pinkTextSecondary"), lineWidth: 1)
                )
        }
        .glassEffect(.regular.interactive())
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryGlassButton(title: "Start Now") {}
        PrimaryGlassButton(title: "Continue") {}
    }
    .padding()
    .background(.ultraThinMaterial)
}

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
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .foregroundStyle(.white)
        }
        .glassEffect(.regular.tint(.pinkTextPrimary.opacity(0.6)).interactive())
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryGlassButton(title: "Start Now") {}
        PrimaryGlassButton(title: "Continue") {}
    }
    .padding()
//    .background(.black)
}

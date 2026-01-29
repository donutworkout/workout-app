//
//  CountdownOverlay.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 19/01/26.
//

import SwiftUI

struct CountdownOverlay: View {
    let countdown: Int
    let scale: CGFloat
    let opacity: Double

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            ZStack {
                Circle()
                    .stroke(Color("pinkTextPrimary").opacity(0.9), lineWidth: 4)
                    .frame(width: 150, height: 150)

                Circle()
                    .fill(Color("pinkTextPrimary").opacity(0.9))
                    .frame(width: 122, height: 122)

                Text("\(countdown)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.7))
                    .monospacedDigit()
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .transition(.opacity)
    }
}

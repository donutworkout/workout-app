//
//  Alert.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 12/11/25.
//

import SwiftUI

struct Alert: View {
    let characterImage: String
    var onResume: () -> Void
    var onEndWorkout: () -> Void

    var body: some View {
        ZStack {
            // Background gelap transparan
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        onResume()
                    }
                }

            VStack(spacing: 0) {
                // MARK: - Karakter di atas kotak
                Image("characterFreeze")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .zIndex(1)

                // MARK: - Kotak putih besar
                VStack {
                    VStack(spacing: 14) {
                        PrimaryGlassButton(title: "Resume") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                onResume()
                            }
                        }

                        NeutralGlassButton(title: "End Workout") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                onEndWorkout()
                            }
                        }
                    }
                    .padding(.bottom, -24)
                }
                .frame(maxWidth: 500, minHeight: 240)
                .padding(.horizontal, 40)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white)
                )
                .padding(.top, -75)
            }
            .padding(.horizontal, 24)
            .transition(.scale.combined(with: .opacity))
        }
        .onAppear {
                    HapticManager.shared.trigger(.alertAppear)
                }
        .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    struct AlertPreviewWrapper: View {
        @State private var showPausePopup = true

        var body: some View {
            ZStack {
                LinearGradient(
                    colors: [.white, .pink.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if showPausePopup {
                    Alert(
                        characterImage: "buttercup",
                        onResume: { showPausePopup = false },
                        onEndWorkout: { showPausePopup = false }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }

    return AlertPreviewWrapper()
}

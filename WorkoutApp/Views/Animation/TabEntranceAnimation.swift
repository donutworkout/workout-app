//
// TabEntranceAnimation.swift
// WorkoutApp
//
// Created by Jennifer Evelyn on 24/11/25.
//

import SwiftUI

// MARK: - Reusable Tab Animation Modifier
struct TabAnimationModifier: ViewModifier {
    let tabIndex: Int
    @Binding var currentTab: Int
    let delay: Double
    let animationType: AnimationType
    
    enum AnimationType {
        case header      // Slide dari atas
        case card        // Scale + rotation 3D
    }
    
    @State private var isVisible: Bool = false
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var yOffset: CGFloat = -30
    
    func body(content: Content) -> some View {
        Group {
            if animationType == .header {
                content
                    .opacity(opacity)
                    .offset(y: yOffset)
            } else {
                content
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotation3DEffect(
                        .degrees(isVisible ? 0 : 25),
                        axis: (x: 0.3, y: 1, z: 0),
                        perspective: 0.4
                    )
            }
        }
        .onChange(of: currentTab) { oldValue, newValue in
            if newValue == tabIndex {
                print("🎬 Tab \(tabIndex) - Animation TRIGGERED!")
                resetAnimation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    playAnimation()
                }
            } else {
                resetAnimation()
            }
        }
        .onAppear {
            if currentTab == tabIndex {
                print("🎬 Tab \(tabIndex) - First appear animation")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    playAnimation()
                }
            }
        }
    }
    
    private func playAnimation() {
        if animationType == .header {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(delay + 0.1)) {
                opacity = 1
                yOffset = 0
            }
        } else {
            withAnimation(.spring(response: 1.1, dampingFraction: 0.75).delay(delay + 0.1)) {
                isVisible = true
                scale = 1.0
                opacity = 1
            }
        }
    }
    
    private func resetAnimation() {
        isVisible = false
        opacity = 0
        if animationType == .header {
            yOffset = -30
        } else {
            scale = 0.7
            // Set rotasi balik ke 12 derajat atau 0 sesuai kebutuhan
        }
    }
}

// MARK: - View Extensions
extension View {
    /// Animasi untuk header yang slide dari atas
    func animateHeader(forTab tabIndex: Int, currentTab: Binding<Int>, delay: Double = 0.1) -> some View {
        self.modifier(TabAnimationModifier(
            tabIndex: tabIndex,
            currentTab: currentTab,
            delay: delay,
            animationType: .header
        ))
    }
    
    /// Animasi untuk card yang scale + rotate 3D
    func animateCard(forTab tabIndex: Int, currentTab: Binding<Int>, delay: Double = 0.3) -> some View {
        self.modifier(TabAnimationModifier(
            tabIndex: tabIndex,
            currentTab: currentTab,
            delay: delay,
            animationType: .card
        ))
    }
}

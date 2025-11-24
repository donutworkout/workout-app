//
//  PageAnimation.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 24/11/25.
//

import SwiftUI

// MARK: - Page Animation Modifier (untuk non-tab pages)
struct PageAnimationModifier: ViewModifier {
    let delay: Double
    let animationType: PageAnimationType
    
    enum PageAnimationType {
        case fadeSlide      // Fade in + slide dari atas (untuk header/title)
        case scaleRotate    // Scale + rotation 3D (untuk card/content)
        case imageBounce    // Scale + rotation lebih dramatis (untuk gambar besar)
    }
    
    @State private var isAnimated: Bool = false
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var yOffset: CGFloat = -30
    @State private var rotation: Double = 20
    
    func body(content: Content) -> some View {
        Group {
            switch animationType {
            case .fadeSlide:
                content
                    .opacity(opacity)
                    .offset(y: yOffset)
                
            case .scaleRotate:
                content
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotation3DEffect(
                        .degrees(isAnimated ? 0 : rotation),
                        axis: (x: 0.3, y: 1, z: 0),
                        perspective: 0.5
                    )
                
            case .imageBounce:
                content
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotation3DEffect(
                        .degrees(isAnimated ? 0 : 25),
                        axis: (x: 0.2, y: 1, z: 0),
                        perspective: 0.4
                    )
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                triggerAnimation()
            }
        }
    }
    
    private func triggerAnimation() {
        switch animationType {
        case .fadeSlide:
            withAnimation(.spring(response: 1.0, dampingFraction: 0.85).delay(delay)) {
                opacity = 1
                yOffset = 0
            }
        case .scaleRotate:
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8).delay(delay)) {
                isAnimated = true
                scale = 1.0
                opacity = 1
            }
            // Kurangi rotasi dari 20 derajat ke 10 derajat
            rotation = 10
        case .imageBounce:
            withAnimation(.spring(response: 1.3, dampingFraction: 0.85).delay(delay)) {
                isAnimated = true
                scale = 1.0
                opacity = 1
            }
            // Kurangi rotasi dari 25 derajat ke 12 derajat
            rotation = 12
        }
    }
}

// MARK: - View Extension untuk Page Animation
extension View {
    /// Animasi fade + slide dari atas (untuk header/title)
    /// Usage: Text("Title").pageHeaderAnimation(delay: 0.1)
    func pageHeaderAnimation(delay: Double = 0.1) -> some View {
        self.modifier(PageAnimationModifier(delay: delay, animationType: .fadeSlide))
    }
    
    /// Animasi scale + rotation 3D (untuk card/content/button)
    /// Usage: VStack { ... }.pageCardAnimation(delay: 0.3)
    func pageCardAnimation(delay: Double = 0.3) -> some View {
        self.modifier(PageAnimationModifier(delay: delay, animationType: .scaleRotate))
    }
    
    /// Animasi khusus untuk gambar besar dengan bounce dramatis
    /// Usage: Image("workout").pageImageAnimation(delay: 0.2)
    func pageImageAnimation(delay: Double = 0.2) -> some View {
        self.modifier(PageAnimationModifier(delay: delay, animationType: .imageBounce))
    }
}

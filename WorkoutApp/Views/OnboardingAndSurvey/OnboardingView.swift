//
//  OnboardingView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 17/11/25.
//

import SwiftUI
import Lottie

struct OnboardingView: View {
    @EnvironmentObject var router: Router
    
    // Continuous animations
    @State private var wiggle = false
    @State private var bgWiggle = false
    
    // MARK: - Entrance Animation States
    @State private var showContent: Bool = false
    @State private var characterScale: CGFloat = 0.5
    @State private var characterOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var buttonOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.8
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background with breathing motion
                BackgroundPink()
                    .scaleEffect(bgWiggle ? 1.09 : 1)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                            bgWiggle = true
                        }
                    }
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // MARK: - Character with Entrance + Wiggle Animation
                    CharLogin()
                        .scaleEffect(characterScale * 1.25)
                        .opacity(characterOpacity)
                        .rotation3DEffect(
                            .degrees(showContent ? 0 : 15),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .rotationEffect(.degrees(wiggle ? 3 : -3))
                        .onAppear {
                            // Start wiggle after entrance animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                                    wiggle = true
                                }
                            }
                        }
                    
                    // MARK: - Title with Fade In
                    VStack(spacing: 8) {
                        Text("Hey, I'm Loona!")
                            .font(.title.bold())
                            .foregroundColor(Color("pinkTextPrimary"))
                        
                        Text("Let's get stronger every cycle")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("pinkTextSecondary"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)
                    
                    Spacer()
                    
                    // MARK: - Button with Pop Animation
                    PrimaryGlassButton(title: "Start Your Journey") {
                        router.navigateTo(.healthConnect)
                        HapticManager.shared.trigger(.buttonTap)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                    .opacity(buttonOpacity)
                    .scaleEffect(buttonScale)
                }
                .padding()
                .navigationBarBackButtonHidden(true)
            }
        }
        .onAppear {
            startEntranceAnimation()
        }
    }
    
    // MARK: - Entrance Animation Sequence
    private func startEntranceAnimation() {
        // Step 1: Character pop in with bounce (0.3s delay)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
            characterScale = 1.0
            characterOpacity = 1.0
            showContent = true
        }
        
        // Step 2: Title fade in + slide up (0.6s delay)
        withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
            titleOpacity = 1.0
            titleOffset = 0
        }
        
        // Step 3: Button pop in (0.9s delay)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.9)) {
            buttonOpacity = 1.0
            buttonScale = 1.0
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(Router())
}

// MARK: - Background Pink
struct BackgroundPink: View {
    var body: some View {
        Image("backgroundOnboarding")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

// MARK: - Character Image
struct CharLogin: View {
    var body: some View {
        Image("charLogin")
            .resizable()
            .scaledToFit()
            .padding(.top, 20)
    }
}

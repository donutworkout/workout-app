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
    @State private var wiggle = false
    @State private var bgWiggle = false
    
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
                    
                    // Character with wiggle animation
                    CharLogin()
                        .scaleEffect(1.25)
                        .rotationEffect(.degrees(wiggle ? 3 : -3))
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                                wiggle = true
                            }
                        }
                    
                    // Title
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
                    
                    Spacer()
                    
                    PrimaryGlassButton(title: "Start Your Journey") {
                        router.navigateTo(.healthConnect)
                        HapticManager.shared.trigger(.buttonTap)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .padding()
                .navigationBarBackButtonHidden(true)
            }
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

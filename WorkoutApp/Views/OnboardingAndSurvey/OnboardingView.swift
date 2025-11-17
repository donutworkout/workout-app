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
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundPink()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // MARK: - Character
                    CharLogin()
                        .frame(height: 350)
                    
                    // MARK: - Title
                    VStack(spacing: 8) {
                        Text("Welcome to the Arena")
                            .font(.largeTitle.bold())
                            .foregroundColor(Color("pinkTextPrimary"))
                        
                        Text("Get stronger every single day!")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("pinkTextSecondary"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // MARK: - Next Button
                    PrimaryGlassButton(title: "Start Your Journey") {
                        router.navigateTo(.healthConnect)
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

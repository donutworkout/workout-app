//
//  OnboardingView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI
import AuthenticationServices
import Lottie

struct OnboardingView: View {
    @State private var navigateToSurvey = false
    @EnvironmentObject var router: Router
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
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
                
                // MARK: - Mascot Animation
                LottieView(name: "characterAnimation", loopMode: .loop)
                    .frame(width: 300, height: 300)
                    .scaleEffect(0.35)
                
                Spacer()
                
                // MARK: - Next Button (tanpa login)
                PrimaryGlassButton(title: "Next") {
                    withAnimation(.easeInOut) {
                        router.navigateTo(.healthConnect)
                    }
                }
                .padding(.horizontal)
                
                // MARK: - OR Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                    Text("or")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(.horizontal, 40)
                
//                // MARK: - Sign in with Apple
//                SignInWithAppleButton(.signIn) { request in
//                    request.requestedScopes = [.fullName, .email]
//                } onCompletion: { result in
//                    switch result {
//                    case .success:
//                        withAnimation(.easeInOut) {
//                            router.navigateTo(.healthConnect)
//                        }
//                    case .failure(let error):
//                        print("❌ Apple Sign-In failed: \(error.localizedDescription)")
//                    }
//                }
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .padding()
            .background(Color.white.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(Router())
}

//
//  OnboardingView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI
import AuthenticationServices

struct OnboardingView: View {
    @State private var navigateToSurvey = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
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
                
                Image("character")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .padding(.vertical, 16)
                    .accessibilityLabel("Mascot character")
                
                Spacer()
                
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                            let userID = credential.user
                            let identityToken = credential.identityToken.flatMap { String(data: $0, encoding: .utf8) }
                            let authorizationCode = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }
                            print("✅ Apple Sign-In success: user=\(userID), token=\(identityToken ?? "nil"), code=\(authorizationCode ?? "nil")")
                        }
                        withAnimation(.easeInOut) {
                            navigateToSurvey = true
                        }
                        
                    case .failure(let error):
                        print("❌ Apple Sign-In failed: \(error.localizedDescription)")
                    }
                }
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .padding()
            .background(Color(.systemBackground))
            .navigationDestination(isPresented: $navigateToSurvey) {
                SurveyView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    OnboardingView()
}

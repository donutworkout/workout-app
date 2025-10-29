//
//  ProfileView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 20/10/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // MARK: - Header
            Text("Profile")
                .font(.system(size: 32, weight: .bold))
                .padding(.top, 30)
                .padding(.horizontal)
            
            // MARK: - Profile Info
            HStack(alignment: .center , spacing: 12) {
                Image("profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                
                Text("Si Jamety")
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.horizontal)
            
            // MARK: - Personalize Section
            Text("PERSONALIZE")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.grayTextPrimary)
                .padding(.horizontal)
                .padding(.bottom, -20)
            
            VStack(spacing: 0) {
                // Body Measurement → SurveyBodyInfo
                Button {
                    router.navigateTo(.surveyBodyInfo)
                } label: {
                    ProfileRow(icon: "figure.arms.open", title: "Body Measurement")
                }
                Divider().padding(.leading, 52)
                
                // Change Goal → SurveyMotivation
                Button {
                    router.navigateTo(.surveyMotivation)
                } label: {
                    ProfileRow(icon: "face.smiling", title: "Change Goal")
                }
                Divider().padding(.leading, 52)
                
                // About Me → Edit Profile
                Button {
                    router.navigateTo(.editProfile)
                } label: {
                    ProfileRow(icon: "person.crop.circle", title: "About Me")
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal)
            
            // MARK: - Menstrual Cycle Section
            Text("MENSTRUAL CYCLE")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.grayTextPrimary)
                .padding(.horizontal)
                .padding(.bottom, -20)
            
            Button {
                router.navigateTo(.menstrualCycle)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("You’re on Day 14 - Ovulation phase")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        Text("Next period predicted: 25 October 2025")
                            .font(.system(size: 14))
                            .foregroundColor(.grayTextPrimary)
                    }
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.grayTextPrimary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }
}

#Preview {
    ProfileView()
        .environmentObject(Router()) // biar preview-nya jalan
}

//
//  ProfileView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 20/10/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var router: Router
    @State private var path: [String] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Header
                    Text("Profile")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 32)
                    
                    // MARK: - Profile Info
                    HStack(alignment: .center, spacing: 12) {
                        Image("profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        
                        Text("Si Jamety")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    // MARK: - Personalize Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PERSONALIZE")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                        
                        VStack(spacing: 0) {
                            NavigationLink {
                                EditBodyInfoView()
                            } label: {
                                ProfileRow(icon: "figure.arms.open", title: "Body Measurement")
                            }
                            
                            NavigationLink {
                                EditWorkoutLevelView()
                            } label: {
                                ProfileRow(icon: "face.smiling", title: "Change Level")
                            }

                            NavigationLink {
                                EditProfileView()
                            } label: {
                                ProfileRow(icon: "person.crop.circle", title: "About Me")
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                        )
                    }
                    
                    // MARK: - Menstrual Cycle Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MENSTRUAL CYCLE")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                        
                        NavigationLink {
                            MenstrualCycleView()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("You're on Day 14 - Ovulation phase")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text("Next period predicted: 25 October 2025")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                            )
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40) 
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            
            // MARK: - Navigation destinations
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "editBodyInfo":
                    EditBodyInfoView()
                case "editWorkoutLevel":
                    EditWorkoutLevelView()
                case "editProfile":
                    EditProfileView()
                case "menstrualCycle":
                    MenstrualCycleView()
                default:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(Router())
}

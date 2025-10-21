//
//  EditProfileView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 21/10/25.
//

import SwiftUI

struct EditProfileView: View {
    @State private var name: String = "Si Jamety"
    @State private var yearOfBirth: String = "2003"
    @State private var height: String = "155 cm"
    @State private var weight: String = "55 kg"
    @State private var goal: String = "Lose weight"
    @State private var workout: String = "Bodyweight"
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Title
            Text("Edit Profile")
                .font(.system(size: 22, weight: .semibold))
                .padding(.top, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Profile Box
                    VStack(spacing: 24) {
                        // Avatar
                        ZStack(alignment: .bottomTrailing) {
                            Image("profile")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            
                            Circle()
                                .fill(Color("pinkTextSecondary"))
                                .frame(width: 36, height: 36)
                                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 16, weight: .semibold))
                                )
                        }
                        .padding(.top, 10)
                        
                        // Fields
                        VStack(spacing: 16) {
                            ProfileTextField(title: "Name", text: $name)
                            ProfileTextField(title: "Year of Birth", text: $yearOfBirth)
                            ProfileTextField(title: "Height", text: $height)
                            ProfileTextField(title: "Weight", text: $weight)
                            ProfileTextField(title: "Goal", text: $goal)
                            ProfileTextField(title: "Preferenced Workout", text: $workout)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    
                    PrimaryGlassButton(title: "Done") {
                        print("Profile saved ✅")
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 40)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

// MARK: - Reusable Profile Text Field
struct ProfileTextField: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            TextField("", text: $text)
                .disabled(true)
                .foregroundColor(.grayTextPrimary)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(.grayTextInput)
                .cornerRadius(50)
        }
    }
}

#Preview {
    EditProfileView()
}

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
    @State private var isEditing: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - Header (pakai HeaderButton)
            HeaderButton(
                title: "Edit Profile",
                isEditing: isEditing,
                onClose: { dismiss() },
                onEditToggle: {
                    withAnimation {
                        isEditing.toggle()
                    }
                }
            )
            .padding(.horizontal)
            .padding(.top, 8)
            
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
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .semibold))
                                )
                        }
                        .padding(.top, 10)
                        
                        // Fields
                        VStack(spacing: 16) {
                            ProfileTextField(title: "Name", text: $name, isEditing: isEditing)
                            ProfileTextField(title: "Year of Birth", text: $yearOfBirth, isEditing: isEditing)
                            ProfileTextField(title: "Height", text: $height, isEditing: isEditing)
                            ProfileTextField(title: "Weight", text: $weight, isEditing: isEditing)
                            ProfileTextField(title: "Goal", text: $goal, isEditing: isEditing)
                            ProfileTextField(title: "Preferenced Workout", text: $workout, isEditing: isEditing)
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
    var isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            
            TextField("", text: $text)
                .disabled(!isEditing)
                .foregroundColor(.grayTextPrimary)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(50)
        }
    }
}

#Preview {
    EditProfileView()
}

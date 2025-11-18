//
//  EditProfileView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 21/10/25.
//

import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \UserProfile.createdAt, order: .reverse)
    private var profiles: [UserProfile]
    
    // Current user profile
    private var currentProfile: UserProfile? {
        profiles.first
    }
    
    // MARK: - State Variables
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var goal: String = ""
    @State private var workoutLevel: String = ""
    @State private var isEditing: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    // ✅ Error states for each field
    @State private var nameError: Bool = false
    @State private var ageError: Bool = false
    @State private var heightError: Bool = false
    @State private var weightError: Bool = false
    @State private var goalError: Bool = false
    @State private var workoutLevelError: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            // ✅ Header with Edit/Save button
            HeaderButton(
                title: "Edit Profile",
                isEditing: isEditing,
                onClose: {
                    dismiss()
                },
                onEditToggle: {
                    withAnimation {
                        if isEditing {
                            validateAndSave()
                        } else {
                            isEditing = true
                        }
                    }
                }
            )
            
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
                            
                            if isEditing {
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
                        }
                        .padding(.top, 10)
                        
                        // Fields
                        VStack(spacing: 16) {
                            ProfileTextField(
                                title: "Name",
                                text: $name,
                                isEditing: isEditing,
                                placeholder: "Enter your name",
                                hasError: nameError,
                                errorMessage: "Name cannot be empty"
                            )
                            
                            ProfileTextField(
                                title: "Age",
                                text: $age,
                                isEditing: isEditing,
                                placeholder: "Enter your age",
                                keyboardType: .numberPad,
                                hasError: ageError,
                                errorMessage: "Age must be a valid number (13-100)"
                            )
                            
                            ProfileTextField(
                                title: "Height (cm)",
                                text: $height,
                                isEditing: isEditing,
                                placeholder: "Enter height in cm",
                                keyboardType: .numberPad,
                                hasError: heightError,
                                errorMessage: "Height must be a valid number (100-250 cm)"
                            )
                            
                            ProfileTextField(
                                title: "Weight (kg)",
                                text: $weight,
                                isEditing: isEditing,
                                placeholder: "Enter weight in kg",
                                keyboardType: .numberPad,
                                hasError: weightError,
                                errorMessage: "Weight must be a valid number (30-200 kg)"
                            )
                            
                            ProfilePickerField(
                                title: "Goal",
                                selection: $goal,
                                options: WorkoutMotivation.allCases.map { $0.displayName },
                                isEditing: isEditing,
                                hasError: goalError,
                                errorMessage: "Please select a goal"
                            )
                            
                            ProfilePickerField(
                                title: "Workout Level",
                                selection: $workoutLevel,
                                options: WorkoutLevel.allCases.map { $0.displayName },
                                isEditing: isEditing,
                                hasError: workoutLevelError,
                                errorMessage: "Please select a workout level"
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadProfileData()
        }
        .alert("Profile Updated", isPresented: $showSaveAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your profile has been successfully updated.")
        }
        .alert("Validation Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Functions
    
    /// Load existing profile data
    private func loadProfileData() {
        guard let profile = currentProfile else {
            print("⚠️ No profile found")
            return
        }
        
        name = profile.name
        age = "\(profile.age)"
        height = "\(profile.height)"
        weight = "\(profile.weight)"
        
        // Load workout goal
        if let workout = profile.userWorkouts?.first {
            goal = workout.workoutMotivation?.displayName ?? "Keep Fit"
            workoutLevel = workout.workoutLevel.displayName
        }
        
        print("✅ Profile data loaded: \(name), \(age) years old")
    }
    
    /// Validate all fields before saving
    private func validateAndSave() {
        // Reset all errors
        nameError = false
        ageError = false
        heightError = false
        weightError = false
        goalError = false
        workoutLevelError = false
        
        var hasError = false
        var errors: [String] = []
        
        // Validate Name
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = true
            errors.append("Name cannot be empty")
            hasError = true
        }
        
        // Validate Age
        if let ageInt = Int(age) {
            if ageInt < 13 || ageInt > 100 {
                ageError = true
                errors.append("Age must be between 13-100")
                hasError = true
            }
        } else {
            ageError = true
            errors.append("Age must be a valid number")
            hasError = true
        }
        
        // Validate Height
        if let heightInt = Int(height) {
            if heightInt < 100 || heightInt > 250 {
                heightError = true
                errors.append("Height must be between 100-250 cm")
                hasError = true
            }
        } else {
            heightError = true
            errors.append("Height must be a valid number")
            hasError = true
        }
        
        // Validate Weight
        if let weightInt = Int(weight) {
            if weightInt < 30 || weightInt > 200 {
                weightError = true
                errors.append("Weight must be between 30-200 kg")
                hasError = true
            }
        } else {
            weightError = true
            errors.append("Weight must be a valid number")
            hasError = true
        }
        
        // Validate Goal
        if goal.isEmpty {
            goalError = true
            errors.append("Please select a goal")
            hasError = true
        }
        
        // Validate Workout Level
        if workoutLevel.isEmpty {
            workoutLevelError = true
            errors.append("Please select a workout level")
            hasError = true
        }
        
        // Show error or save
        if hasError {
            errorMessage = errors.joined(separator: "\n")
            showErrorAlert = true
        } else {
            saveProfile()
        }
    }
    
    /// Save profile changes
    private func saveProfile() {
        guard let profile = currentProfile else {
            print("❌ Cannot save: No profile found")
            return
        }
        
        // Safe to force unwrap since validation passed
        let ageInt = Int(age)!
        let heightInt = Int(height)!
        let weightInt = Int(weight)!
        
        // Update profile
        profile.name = name.trimmingCharacters(in: .whitespaces)
        profile.age = ageInt
        profile.height = heightInt
        profile.weight = weightInt
        
        // Update workout data
        if let workout = profile.userWorkouts?.first {
            // Update motivation
            if let motivation = WorkoutMotivation.allCases.first(where: { $0.displayName == goal }) {
                workout.workoutMotivation = motivation
            }
            
            // Update level
            if let level = WorkoutLevel.allCases.first(where: { $0.displayName == workoutLevel }) {
                workout.workoutLevel = level
            }
        }
        
        // Save to database
        do {
            try modelContext.save()
            print("✅ Profile saved successfully")
            isEditing = false
            showSaveAlert = true
        } catch {
            print("❌ Error saving profile: \(error.localizedDescription)")
            errorMessage = "Failed to save profile. Please try again."
            showErrorAlert = true
        }
    }
}

// MARK: - Reusable Profile Text Field
struct ProfileTextField: View {
    var title: String
    @Binding var text: String
    var isEditing: Bool
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default
    var hasError: Bool = false
    var errorMessage: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            
            TextField(placeholder, text: $text)
                .disabled(!isEditing)
                .keyboardType(keyboardType)
                .foregroundColor(isEditing ? .black : .gray)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(isEditing ? Color.gray.opacity(0.15) : Color.gray.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(
                            hasError ? Color.red : (isEditing ? Color("pinkTextPrimary").opacity(0.3) : Color.clear),
                            lineWidth: hasError ? 2 : 1
                        )
                )
            
            // ✅ Error message
            if hasError && isEditing {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                    
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: hasError)
    }
}

// MARK: - Profile Picker Field (for dropdowns)
struct ProfilePickerField: View {
    var title: String
    @Binding var selection: String
    var options: [String]
    var isEditing: Bool
    var hasError: Bool = false
    var errorMessage: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            
            if isEditing {
                Menu {
                    ForEach(options, id: \.self) { option in
                        Button(option) {
                            selection = option
                        }
                    }
                } label: {
                    HStack {
                        Text(selection.isEmpty ? "Select \(title.lowercased())" : selection)
                            .foregroundColor(selection.isEmpty ? .gray : .black)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .fill(Color.gray.opacity(0.15))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(
                                hasError ? Color.red : Color("pinkTextPrimary").opacity(0.3),
                                lineWidth: hasError ? 2 : 1
                            )
                    )
                }
            } else {
                Text(selection)
                    .foregroundColor(.gray)
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .fill(Color.gray.opacity(0.08))
                    )
            }
            
            // ✅ Error message
            if hasError && isEditing {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                    
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: hasError)
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
            .modelContainer(for: [UserProfile.self, UserWorkout.self, UserCycle.self])
    }
}

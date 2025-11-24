//
//  ProfileView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 23/10/25.
//

import SwiftUI
import SwiftData

struct AboutMeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var router: Router
    
    @State private var isEditingFromProfile: Bool = false
    @State private var showUnsavedAlert: Bool = false
    
    @Query(sort: \UserProfile.createdAt, order: .reverse)
    private var profiles: [UserProfile]
    
    private var currentProfile: UserProfile? { profiles.first }
    
    @State private var name: String = ""
    @State private var yearOfBirth: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var workoutLevel: String = "Intermediate"
    @State private var workoutDays: String = "Monday, Wednesday, Saturday"
    
    @State private var hasChanges: Bool = false
    @State private var showValidation: Bool = false
    
    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    // Validation
    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var isYearValid: Bool {
        guard let year = Int(yearOfBirth) else { return false }
        return year >= 1900 && year <= currentYear
    }
    
    private var isHeightValid: Bool {
        guard let heightValue = Int(height) else { return false }
        return heightValue >= 50 && heightValue <= 250
    }
    
    private var isWeightValid: Bool {
        guard let weightValue = Int(weight) else { return false }
        return weightValue >= 20 && weightValue <= 300
    }
    
    private var isFormValid: Bool {
        let nameCheck = isNameValid
        let yearCheck = isYearValid
        let heightCheck = isHeightValid
        let weightCheck = isWeightValid
        return nameCheck && yearCheck && heightCheck && weightCheck
    }
    
    private func saveUserProfile() {
        showValidation = true
        
        guard isFormValid, let profile = currentProfile else {
            return
        }
        
        profile.name = name
        
        if let year = Int(yearOfBirth) {
            profile.age = currentYear - year
        }
        
        if let heightValue = Int(height) {
            profile.height = heightValue
        }
        
        if let weightValue = Int(weight) {
            profile.weight = weightValue
        }
        
        do {
            try modelContext.save()
            hasChanges = false
            showValidation = false
        } catch {
            print("❌ Error saving profile: \(error.localizedDescription)")
        }
    }

    
    private func saveAndDismiss() {
        showValidation = true
        
        guard isFormValid, let profile = currentProfile else {
            return
        }
        
        profile.name = name
        
        if let year = Int(yearOfBirth) {
            profile.age = currentYear - year
        }
        
        if let heightValue = Int(height) {
            profile.height = heightValue
        }
        
        if let weightValue = Int(weight) {
            profile.weight = weightValue
        }
        
        do {
            try modelContext.save()
            hasChanges = false
            showValidation = false
            
            // ✅ Set ke profile tab dan navigate
            router.selectedTab = 2
            router.navigateTo(.profile)  // Ini akan trigger TabBarView dengan selectedTab = 2
        } catch {
            print("❌ Error saving profile: \(error.localizedDescription)")
        }
    }

    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                // X Button
                Button {
                    if hasChanges {
                        showUnsavedAlert = true  // Tampilkan alert jika ada perubahan
                    } else {
                        dismiss()  // Langsung close jika tidak ada perubahan
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("About Me")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Save button (HANYA SATU)
                if hasChanges {
                    Button {
                        saveAndDismiss()  // Save dan auto dismiss
                    } label: {
                        Text("Save")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("pinkTextPrimary"))
                    }
                } else {
                    Color.clear.frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white)

            
            // MARK: - Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Profile Image
                    Image("profile")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding(.top, 12)
                    
                    // MARK: - Personal Info Card (Frame 1)
                    VStack(alignment: .leading, spacing: 12) {
                        // Name
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Name")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                            
                            HStack(spacing: 8) {
                                TextField("Enter your name", text: $name)
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                                    .onChange(of: name) { hasChanges = true }
                                
                                if showValidation && !isNameValid {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 18))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            
                            if showValidation && !isNameValid {
                                Text("Name cannot be empty")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Year of Birth
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Year of Birth")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                            
                            HStack(spacing: 8) {
                                TextField("2003", text: $yearOfBirth)
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                                    .keyboardType(.numberPad)
                                    .onChange(of: yearOfBirth) { hasChanges = true }
                                
                                if showValidation && !isYearValid {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 18))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            
                            if showValidation && !isYearValid {
                                Text("Year must be between 1900 and 2025")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Height
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Height")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                            
                            HStack(spacing: 8) {
                                TextField("155", text: $height)
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                                    .keyboardType(.numberPad)
                                    .onChange(of: height) { hasChanges = true }
                                
                                Text("cm")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                
                                if showValidation && !isHeightValid {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 18))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            
                            if showValidation && !isHeightValid {
                                Text("Height must be between 50-250 cm")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Weight
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Weight")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                            
                            HStack(spacing: 8) {
                                TextField("55", text: $weight)
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                                    .keyboardType(.numberPad)
                                    .onChange(of: weight) { hasChanges = true }
                                
                                Text("kg")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                
                                if showValidation && !isWeightValid {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 18))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            
                            if showValidation && !isWeightValid {
                                Text("Weight must be between 20-300 kg")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    
                    // MARK: - Plan Setup Card (Frame 2)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PLAN SETUP")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        // Workout Level
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Workout Level")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text(workoutLevel)
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        // Workout Day
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Workout Day")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text(workoutDays)
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        // Di AboutMeView.swift
                        PrimaryGlassButton(title: "Change in Survey") {
                            if hasChanges && isFormValid {
                                saveUserProfile()
                            }
                            router.isEditingFromProfile = true  // ✅ Set flag
                            dismiss()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                router.navigateTo(.surveyWorkoutLevel)
                            }
                        }
                        .frame(height: 54)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            loadUserProfile()
        }
        .alert("Unsaved Changes", isPresented: $showUnsavedAlert) {
            Button("Discard", role: .destructive) {
                router.selectedTab = 2
                router.navigateTo(.profile)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You have unsaved changes. Do you want to discard them?")
        }
    }
    
    // MARK: - Add Query for UserWorkout
    @Query(sort: \UserWorkout.createdAt, order: .reverse)
    private var userWorkouts: [UserWorkout]

    private var currentWorkout: UserWorkout? {
        userWorkouts.first { $0.user?.id == currentProfile?.id }
    }

    // MARK: - Functions
    private func loadUserProfile() {
        guard let profile = currentProfile else { return }
        name = profile.name
        
        // Convert age to year of birth
        let birthYear = currentYear - profile.age
        yearOfBirth = "\(birthYear)"
        
        height = "\(profile.height)"
        weight = "\(profile.weight)"
        
        // ✅ Load workout preferences from UserWorkout
        if let workout = currentWorkout {
            // Workout Level
            workoutLevel = workout.workoutLevel.displayName
            
            // Workout Days - format as comma-separated string
            let days = workout.workoutDaysPreference.map { $0.displayName }
            workoutDays = days.joined(separator: ", ")
        } else {
            workoutLevel = "Not set"
            workoutDays = "Not set"
        }
        
        hasChanges = false
        showValidation = false
    }
}

#Preview {
    AboutMeView()
        .environmentObject(Router())
        .modelContainer(for: [UserProfile.self, UserWorkout.self, UserCycle.self])
}

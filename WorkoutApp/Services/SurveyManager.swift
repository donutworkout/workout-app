//
//  SurveyManager.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 20/10/25.
//

import SwiftUI
import SwiftData

//@Observable
class SurveyManager : ObservableObject {
    var modelContext: ModelContext
    
    // Temporary data (UserProfile)
    var tempName: String = ""
    var tempAge: Int = 0
    var tempWeight: Int = 0
    var tempHeight: Int = 0
    
    // Temporary data (UserCycle)
    var tempIsCycleRegular: Bool = true
    var tempCycleStartDate: Date = Date()
    var tempCycleEndDate: Date = Date()
    var tempCycleLength: Int = 0
    var tempCycleSymptoms: [CycleSymptoms] = []
    var tempCycleEnergy: CycleEnergy = .stable
    var tempCycleMoodAffectsMotivation: CycleMoodAffectsMotivation = .never
    
    // Temporary data (UserWorkout)
    var tempWorkoutMotivation: WorkoutMotivation = .keepFit
    var tempWorkoutTimesAWeek: WorkoutTimesAWeek = .twoToThreeTimes // berapa kali olahraga dalam seminggu
    var tempWorkoutDuration: WorkoutDuration = .thirtyToSixtyMinutes
    var tempWorkoutIntensity: WorkoutIntensity = .light
    var tempWorkoutExperience: WorkoutExperience = .oneToThreeMonths // sudah berapa lama berolahraga
    var tempWorkoutLevel: WorkoutLevel = .beginner
    var tempWorkoutDaysPreference: [WorkoutDayPreference] = []
    
    // The models
    var userProfile: UserProfile?
    var userWorkout: UserWorkout?
    var userCycle: UserCycle?
    
    var isProfileComplete: Bool = false
    var isWorkoutComplete: Bool = false
    var isCycleComplete: Bool = false
    
    var currentCyclePhase: MenstrualPhase {
        return CyclePhaseCalculator.calculateCurrentPhase(
            lastPeriodStart: tempCycleStartDate,
            cycleLength: tempCycleLength,
            menstrualDuration: 5 //bisa diganti pake hasil dari rumus nanti
        )
    }
    
    var daysUntilNextPeriod: Int? {
        guard let nextPeriod = CyclePhaseCalculator.predictNextPeriod(
            lastPeriodStart: tempCycleStartDate,
            cycleLength: tempCycleLength > 0 ? tempCycleLength : 28
        ) else { return nil }
        
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: nextPeriod).day
    }
    
    var currentDayInCycle: Int {
        let calendar = Calendar.current
        let daysSinceStart = calendar.dateComponents([.day], from: tempCycleStartDate, to: Date()).day ?? 0

        return (daysSinceStart % tempCycleLength) + 1
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.loadExistingData()
    }
    
    private func loadExistingData() {
        // MARK: - UserProfile
        var profileDescriptor = FetchDescriptor<UserProfile>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        if let profiles = try? modelContext.fetch(profileDescriptor), !profiles.isEmpty {
            userProfile = profiles.first
            isProfileComplete = true
            
            // Delete extras
            if profiles.count > 1 {
                for extra in profiles.dropFirst() {
                    modelContext.delete(extra)
                }
                try? modelContext.save()
                print("🧹 Deleted duplicate UserProfiles (\(profiles.count - 1))")
            }
            
            // Populate temp data
            if let existingProfile = userProfile {
                tempName = existingProfile.name
                tempAge = existingProfile.age
                tempWeight = existingProfile.weight
                tempHeight = existingProfile.height
            }
        }

        // MARK: - UserWorkout
        var workoutDescriptor = FetchDescriptor<UserWorkout>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        if let workouts = try? modelContext.fetch(workoutDescriptor), !workouts.isEmpty {
            userWorkout = workouts.first
            isWorkoutComplete = true
            
            // Delete extras
            if workouts.count > 1 {
                for extra in workouts.dropFirst() {
                    modelContext.delete(extra)
                }
                try? modelContext.save()
                print("🧹 Deleted duplicate UserWorkouts (\(workouts.count - 1))")
            }
            
            // Populate temp data
            if let existingWorkout = userWorkout {
                tempWorkoutMotivation = existingWorkout.workoutMotivation
                tempWorkoutTimesAWeek = existingWorkout.workoutTimesAWeek
                tempWorkoutDuration = existingWorkout.workoutDuration
                tempWorkoutIntensity = existingWorkout.workoutIntensity
                tempWorkoutExperience = existingWorkout.workoutExperience
                tempWorkoutLevel = existingWorkout.workoutLevel
                tempWorkoutDaysPreference = existingWorkout.workoutDaysPreference
            }
        }

        // MARK: - UserCycle
        var cycleDescriptor = FetchDescriptor<UserCycle>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        if let cycles = try? modelContext.fetch(cycleDescriptor), !cycles.isEmpty {
            userCycle = cycles.first
            isCycleComplete = true
            
            // Delete extras
            if cycles.count > 1 {
                for extra in cycles.dropFirst() {
                    modelContext.delete(extra)
                }
                try? modelContext.save()
                print("🧹 Deleted duplicate UserCycles (\(cycles.count - 1))")
            }
            
            // Populate temp data
            if let existingCycle = userCycle {
                tempIsCycleRegular = existingCycle.isCycleRegular
                tempCycleStartDate = existingCycle.cycleStartDate
                tempCycleEndDate = existingCycle.cycleEndDate
                tempCycleLength = existingCycle.cycleLength
                tempCycleSymptoms = existingCycle.cycleSymptoms
                tempCycleEnergy = existingCycle.cycleEnergy
                tempCycleMoodAffectsMotivation = existingCycle.cycleMoodAffectsMotivation
            }
        }
    }

    
    func calculateWorkoutLevel() -> WorkoutLevel {
        // Extract values from temp variables
        let timesPerWeek = tempWorkoutTimesAWeek
        let duration = tempWorkoutDuration
        let intensity = tempWorkoutIntensity
        let experience = tempWorkoutExperience
        
        // Scoring system
        var beginnerScore = 0
        var intermediateScore = 0
        var advancedScore = 0
        
        // 1. Frequency evaluation (times per week)
        switch timesPerWeek {
        case .twoToThreeTimes:
            beginnerScore += 3
        case .fourToFiveTimes:
            intermediateScore += 3
        case .everyday:
            advancedScore += 3
        }
        
        // 2. Duration evaluation (per session)
        switch duration {
        case .underThirtyMinutes:
            beginnerScore += 3
        case .thirtyToSixtyMinutes:
            intermediateScore += 3
        case .aboveSixtyMinutes:
            advancedScore += 3
        }
        
        // 3. Intensity evaluation
        switch intensity {
        case .light:
            beginnerScore += 3
        case .moderate:
            beginnerScore += 1
            intermediateScore += 2
        case .hard:
            intermediateScore += 2
            advancedScore += 1
        case .superIntense:
            advancedScore += 3
        }
        
        // 4. Experience evaluation (adherence/consistency)
        switch experience {
        case .underOneMonth:
            beginnerScore += 3
        case .oneToThreeMonths:
            beginnerScore += 1
            intermediateScore += 2
        case .fourToSixMonths:
            intermediateScore += 2
            advancedScore += 1
        case .moreThanSixMonths:
            advancedScore += 3
        }
        
        // Determine level based on highest score
        let maxScore = max(beginnerScore, intermediateScore, advancedScore)
        
        if maxScore == advancedScore && advancedScore >= 8 {
            return .advanced
        } else if maxScore == intermediateScore && intermediateScore >= 6 {
            return .intermediate
        } else {
            return .beginner
        }
    }
    
    func finalizeUserProfile() {
        if userProfile == nil {
            // Create new profile
            let newProfile = UserProfile(
                name: tempName,
                age: tempAge,
                weight: tempWeight,
                height: tempHeight
            )
            userProfile = newProfile
            modelContext.insert(newProfile)
        } else {
            // Update existing profile
            userProfile?.name = tempName
            userProfile?.age = tempAge
            userProfile?.weight = tempWeight
            userProfile?.height = tempHeight
        }
        
        isProfileComplete = true
        print("UserProfile finalized")
        save()
    }
    
    func finalizeUserWorkout() {
        
        tempWorkoutLevel = calculateWorkoutLevel()
        
        if userWorkout == nil {
            // Create new workout
            let newWorkout = UserWorkout(
                workoutMotivation: tempWorkoutMotivation,
                workoutTimesAWeek: tempWorkoutTimesAWeek,
                workoutDuration: tempWorkoutDuration,
                workoutIntensity: tempWorkoutIntensity,
                workoutExperience: tempWorkoutExperience,
                workoutLevel: tempWorkoutLevel,
                workoutDaysPreference: tempWorkoutDaysPreference
            )
            newWorkout.user = userProfile
            userWorkout = newWorkout
            modelContext.insert(newWorkout)
        } else {
            // Update existing workout
            userWorkout?.workoutMotivation = tempWorkoutMotivation
            userWorkout?.workoutTimesAWeek = tempWorkoutTimesAWeek
            userWorkout?.workoutDuration = tempWorkoutDuration
            userWorkout?.workoutIntensity = tempWorkoutIntensity
            userWorkout?.workoutExperience = tempWorkoutExperience
            userWorkout?.workoutLevel = tempWorkoutLevel
            userWorkout?.workoutDaysPreference = tempWorkoutDaysPreference
        }
        
        print("UserWorkout finalized")
        isWorkoutComplete = true
        save()
    }
    
    
    func finalizeUserCycle() {
        if userCycle == nil {
            // Create new cycle
            let newCycle = UserCycle(
                isCycleRegular: tempIsCycleRegular,
                cycleStartDate: tempCycleStartDate,
                cycleEndDate: tempCycleEndDate,
                cycleLength: tempCycleLength,
                cycleSymptoms: tempCycleSymptoms,
                cycleEnergy: tempCycleEnergy,
                cycleMoodAffectsMotivation: tempCycleMoodAffectsMotivation
            )
            newCycle.user = userProfile
            userCycle = newCycle
            modelContext.insert(newCycle)
        } else {
            // Update existing cycle
            userCycle?.isCycleRegular = tempIsCycleRegular
            userCycle?.cycleStartDate = tempCycleStartDate
            userCycle?.cycleEndDate = tempCycleEndDate
            userCycle?.cycleLength = tempCycleLength
            userCycle?.cycleSymptoms = tempCycleSymptoms
            userCycle?.cycleEnergy = tempCycleEnergy
            userCycle?.cycleMoodAffectsMotivation = tempCycleMoodAffectsMotivation
        }
        
        isCycleComplete = true
        save()
    }
    
    //Profile updates
    func updateTempName(_ name: String) {
        tempName = name
    }
    
    func updateTempAge(_ age: Int) {
        tempAge = age
    }
    
    func updateTempWeight(_ weight: Int) {
        tempWeight = weight
    }
    
    func updateTempHeight(_ height: Int) {
        tempHeight = height
    }
    
    // Workout updates
    
    func updateTempWorkoutMotivation(_ motivation: WorkoutMotivation) {
        tempWorkoutMotivation = motivation
    }
    
    func updateTempWorkoutTimesAWeek(_ times: WorkoutTimesAWeek) {
        tempWorkoutTimesAWeek = times
    }
    
    func updateTempWorkoutDuration(_ duration: WorkoutDuration) {
        tempWorkoutDuration = duration
    }
    
    func updateTempWorkoutIntensity(_ intensity: WorkoutIntensity) {
        tempWorkoutIntensity = intensity
    }
    
    func updateTempWorkoutExperience(_ experience: WorkoutExperience) {
        tempWorkoutExperience = experience
    }
    
    func updateTempWorkoutLevel() {
        tempWorkoutLevel = calculateWorkoutLevel()
        print("Workout level: \(tempWorkoutLevel)")
    }
    
    func updateTempWorkoutDaysPreference(_ days: [WorkoutDayPreference]) {
        tempWorkoutDaysPreference = days
    }
    
    // Cycle updates
    
    func updateTempIsCycleRegular(_ regular: Bool) {
        tempIsCycleRegular = regular
    }
    
    func updateTempCycleStartDate(_ start_date: Date) {
        tempCycleStartDate = start_date
    }
    
    func updateTempCycleEndDate(_ end_date: Date) {
        tempCycleEndDate = end_date
    }
    
    func updateTempCycleLength(_ length: Int) {
        tempCycleLength = length
    }
    
    func updateTempCycleSymptoms(_ symptoms: [CycleSymptoms]) {
        tempCycleSymptoms = symptoms
    }
    
    func updateTempCycleEnergy(_ energy: CycleEnergy) {
        tempCycleEnergy = energy
    }
    
    func updateTempCycleMoodAffectsMotivation(_ moodAffectsMotivation: CycleMoodAffectsMotivation) {
        tempCycleMoodAffectsMotivation = moodAffectsMotivation
    }
    
    // MARK: - Validation Methods (Optional but recommended)
    //
    //       func isProfileDataValid() -> Bool {
    //           return !tempName.isEmpty && tempAge > 0 && tempWeight > 0 && tempHeight > 0
    //       }
    //
    //       func isWorkoutDataValid() -> Bool {
    //           return tempWorkoutTimesAWeek > 0 && tempWorkoutDuration > 0
    //       }
    //
    //       func isCycleDataValid() -> Bool {
    //           return tempCycleLength > 0
    //       }
    
    // MARK: - Save
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
    
<<<<<<< HEAD
    private func verifyLatestData() {
=======
    func verifyLatestData() {
>>>>>>> origin/develop
        print("\n🗄️ --- SwiftData Latest Data Check ---")
        
        do {
            // 1. Define the sort (assumes you have a 'createdAt' property)
            let sort = SortDescriptor(\UserProfile.createdAt, order: .reverse)
            
            // 2. Create the descriptor (must be a 'var')
            var descriptor = FetchDescriptor<UserProfile>(sortBy: [sort])
            
            // 3. Set the fetchLimit property
            descriptor.fetchLimit = 1
            
            let profiles = try modelContext.fetch(descriptor)
            
            if let profile = profiles.first {
                print("📋 Latest Profile:")
                print("   • Name: \(profile.name)")
                print("   • Age: \(profile.age)")
                print("   • Height: \(profile.height)")
                print("   • Weight: \(profile.weight)")
            } else {
                print("💪 No saved profiles yet.")
            }
        } catch {
            print("❌ Error fetching latest profile: \(error)")
        }
        
        do {
            // 1. Define the sort (assumes you have a 'createdAt' property)
            let sort = SortDescriptor(\UserWorkout.createdAt, order: .reverse)
            
            // 2. Create the descriptor (must be a 'var')
            var descriptor = FetchDescriptor<UserWorkout>(sortBy: [sort])
            
            // 3. Set the fetchLimit property
            descriptor.fetchLimit = 1
            
            let workouts = try modelContext.fetch(descriptor)
            
            if let workout = workouts.first {
                print("💪 Latest Workout:")
                print("   • Motivation: \(workout.workoutMotivation.displayName)")
                print("   • Frequency: \(workout.workoutTimesAWeek.displayName)")
                print("   • Duration: \(workout.workoutDuration.displayName)")
                print("   • Intensity: \(workout.workoutIntensity.displayName)")
                print("   • Level: \(workout.workoutLevel.displayName)")
                let days = workout.workoutDaysPreference.map { $0.displayName }.joined(separator: ", ")
                print("   • Days: \(days)")
            } else {
                print("💪 No saved workouts yet.")
            }
        } catch {
            print("❌ Error fetching latest workout: \(error)")
        }
        
        do {
            // 1. Define the sort (assumes you have a 'createdAt' property)
            let sort = SortDescriptor(\UserCycle.createdAt, order: .reverse)
            
            // 2. Create the descriptor (must be a 'var')
            var descriptor = FetchDescriptor<UserCycle>(sortBy: [sort])
            
            // 3. Set the fetchLimit property
            descriptor.fetchLimit = 1
            
            let cycles = try modelContext.fetch(descriptor)
            
            if let cycle = cycles.first {
                print("🌷 Latest Cycle:")
                print("   • Regular: \(cycle.isCycleRegular)")
                print("   • Start Date: \(cycle.cycleStartDate)")
                print("   • End Date: \(cycle.cycleEndDate)")
                print("   • Length: \(cycle.cycleLength)")
                let symptoms = cycle.cycleSymptoms.map { $0.displayName }.joined(separator: ", ")
                print(#"   • Symptoms: \((symptoms.isEmpty ? "None" : symptoms))"#)
                print("   • Energy: \(cycle.cycleEnergy.displayName)")
                print("   • Mood Affects Motivation: \(cycle.cycleMoodAffectsMotivation.displayName)")
                print("   • Current Phase: \(currentCyclePhase)")
            } else {
                print("💪 No saved workouts yet.")
            }
        } catch {
            print("❌ Error fetching latest workout: \(error)")
        }
    }
}


extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}


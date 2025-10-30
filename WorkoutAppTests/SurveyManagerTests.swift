//
//  SurveyManagerTests.swift
//  WorkoutAppTests
//
//  Created by Nadaa Shafa Nadhifa on 30/10/25.
//

import Testing
import SwiftData
@testable import WorkoutApp

@Suite("Survey Manager Tests")
struct SurveyManagerTests {

    @MainActor
    func createTestContainer() -> ModelContainer {
        let schema = Schema([
            UserProfile.self,
            UserWorkout.self,
            UserCycle.self
        ])
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }
    
    @Test("Initialize SurveyManager with empty database")
    @MainActor
    func testInitializationWithEmptyDatabase() {
        // given
        let container = createTestContainer()
        let context = ModelContext(container)
        
        // when
        let manager = SurveyManager(modelContext: context)
        
        //then
        #expect(manager.userProfile == nil)
        #expect(manager.userWorkout == nil)
        #expect(manager.userCycle == nil)
        #expect(manager.isProfileComplete == false)
        #expect(manager.isWorkoutComplete == false)
        #expect(manager.isCycleComplete == false)
    }
    
    @Test("Initialize SurveyManager with existing profile")
    @MainActor
    func testInitializationWithExistingProfile() {
        //given
        let container = createTestContainer()
        let context = ModelContext(container)
        
        //when
        // Insert existing profile
        let profile = UserProfile(name: "Test User", age: 25, weight: 60, height: 165)
        context.insert(profile)
        try? context.save()
        
        let manager = SurveyManager(modelContext: context)
        
        //then
        #expect(manager.userProfile != nil)
        #expect(manager.tempName == "Test User")
        #expect(manager.tempAge == 25)
        #expect(manager.tempWeight == 60)
        #expect(manager.tempHeight == 165)
        #expect(manager.isProfileComplete == true)
    }
    
    @Test("Update temporary profile data")
    @MainActor
    func testUpdateTempProfileData() {
        //given
        let container = createTestContainer()
        let context = ModelContext(container)
        let manager = SurveyManager(modelContext: context)
        
        //when
        manager.updateTempName("Jane Doe")
        manager.updateTempAge(28)
        manager.updateTempWeight(65)
        manager.updateTempHeight(170)
        
        //then
        #expect(manager.tempName == "Jane Doe")
        #expect(manager.tempAge == 28)
        #expect(manager.tempWeight == 65)
        #expect(manager.tempHeight == 170)
    }
    
    @Test("Delete duplicate profiles on initialization")
    @MainActor
    func testDeleteDuplicateProfiles() {
        //given
        let container = createTestContainer()
        let context = ModelContext(container)
        
        // Insert multiple profiles
        let profile1 = UserProfile(name: "User 1", age: 25, weight: 60, height: 165)
        let profile2 = UserProfile(name: "User 2", age: 30, weight: 70, height: 170)
        let profile3 = UserProfile(name: "User 3", age: 35, weight: 80, height: 175)
        
        //when
        context.insert(profile1)
        context.insert(profile2)
        context.insert(profile3)
        try? context.save()
        
        // Initialize manager (should delete duplicates)
        let manager = SurveyManager(modelContext: context)
        
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = try? context.fetch(descriptor)
        
        //then
        #expect(profiles?.count == 1)
        #expect(manager.userProfile != nil)
    }

}

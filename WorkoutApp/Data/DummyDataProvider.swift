//
//  DummyDataProvider.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 01/11/25.//


import Foundation
import SwiftData

class DummyExerciseProvider {
    static let shared = DummyExerciseProvider()
    
    // MARK: - Create Dummy Exercises
    func createDummyExercises() -> [Exercise] {
        return [
            // MARK: - MENSTRUAL PHASE (Gentle & Low Impact)
            
            Exercise(
                name: "Wall Press",
                bodyPart: [.fullBody, .upperPush],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Shoulder Toner",
                bodyPart: [.fullBody, .upperPush],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Bent Over Row",
                bodyPart: [.fullBody],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Bodyweight Squat",
                bodyPart: [.fullBody],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Glute Bridge",
                bodyPart: [.fullBody],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Dead Bug",
                bodyPart: [.fullBody],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Plank with Knee Dip",
                bodyPart: [.fullBody, .upperPush],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Child Pose",
                bodyPart: [.fullBody],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Tricep Dip",
                bodyPart: [.upperPush],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "One Knee Push Up",
                bodyPart: [.upperPush],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Plank to Downward Dog",
                bodyPart: [.upperPush],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Plank Row",
                bodyPart: [.upperPull],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Knee to Elbow Kick Back",
                bodyPart: [.upperPull],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Squat Jump",
                bodyPart: [.upperPull],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Single Leg Deadlift",
                bodyPart: [.upperPull],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Walking Lunge",
                bodyPart: [.upperPull],
                time: nil,
                imageName: nil
            ),
            
            Exercise(
                name: "Plank with Hip Dips",
                bodyPart: [.upperPull],
                time: nil,
                imageName: nil
            )
        ]
    }
    
    // MARK: - Insert Dummy Data into SwiftData
    func insertDummyData(into context: ModelContext) {
        let exercises = createDummyExercises()
        
        // Check if data already exists
        let descriptor = FetchDescriptor<Exercise>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        if existingCount > 0 {
            print("⚠️ Exercises already exist in database (\(existingCount) exercises)")
            return
        }
        
        // Insert all exercises
        for exercise in exercises {
            context.insert(exercise)
        }
        
        do {
            try context.save()
            print("✅ Successfully inserted \(exercises.count) dummy exercises into SwiftData")
        } catch {
            print("❌ Failed to save exercises: \(error)")
        }
    }
    
    // MARK: - Clear All Exercises (for testing)
    func clearAllExercises(from context: ModelContext) {
        do {
            try context.delete(model: Exercise.self)
            try context.save()
            print("✅ Cleared all exercises from database")
        } catch {
            print("❌ Failed to clear exercises: \(error)")
        }
    }
}

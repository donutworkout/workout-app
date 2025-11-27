//
//  DummyDataProvider.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 01/11/25.//


import Foundation
import SwiftData

class DummyExerciseProvider {
    static let shared = DummyExerciseProvider()
    
    func createDummyExercises() -> [Exercise] {
        return [
            Exercise(
                name: "Wall Press",
                bodyPart: [.fullBody, .upperPush],
                time: 30
            ),
            
            Exercise(
                name: "Shoulder Toner",
                bodyPart: [.fullBody, .upperPush],
                time: nil
            ),
            
            Exercise(
                name: "Bent Over Row",
                bodyPart: [.fullBody],
                time: 30
            ),
            
//            Exercise(
//                name: "Bodyweight Squat",
//                bodyPart: [.fullBody],
//                time: nil
//            ),
            
            Exercise(
                name: "Glute Bridge",
                bodyPart: [.fullBody],
                time: 30
            ),
            
            Exercise(
                name: "Dead Bug",
                bodyPart: [.fullBody],
                time: nil
            ),
            
            Exercise(
                name: "Plank With Knee Dip",
                bodyPart: [.fullBody, .upperPush],
                time: 30
            ),
            
//            Exercise(
//                name: "Child Pose",
//                bodyPart: [.fullBody],
//                time: nil
//            ),
//            
            Exercise(
                name: "Tricep Dip",
                bodyPart: [.upperPush],
                time: 30
            ),
            
            Exercise(
                name: "One Knee Push Up",
                bodyPart: [.upperPush],
                time: nil
            ),
            
//            Exercise(
//                name: "Plank To Downward Dog",
//                bodyPart: [.upperPush],
//                time: nil
//            ),
            
            Exercise(
                name: "Plank Row",
                bodyPart: [.upperPull],
                time: 30
            ),
            
//            Exercise(
//                name: "Knee To Elbow Kick Back",
//                bodyPart: [.upperPull],
//                time: nil
//            ),
            
            Exercise(
                name: "Squat Jump",
                bodyPart: [.upperPull],
                time: nil
            ),
            
            Exercise(
                name: "Single Leg Deadlift",
                bodyPart: [.upperPull],
                time: nil
            ),
            
            Exercise(
                name: "Walking Lunge",
                bodyPart: [.upperPull],
                time: 30
            ),
            
            Exercise(
                name: "Plank With Hip Dips",
                bodyPart: [.upperPull],
                time: nil
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
        let exercises = createDummyExercises()
        
        for exercise in exercises {
            context.insert(exercise)
        }
        
        do {
            try context.delete(model: Exercise.self)
            try context.delete(model: DailyMenu.self)
            try context.save()
            print("✅ Cleared all exercises from database")
            print("there's \(exercises.count) left in the database")
        } catch {
            print("❌ Failed to clear exercises: \(error)")
        }
    }
}

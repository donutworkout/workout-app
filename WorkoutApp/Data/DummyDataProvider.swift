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
                name: "Squat Pulse",
                bodyPart: [.squat],
                time: nil
            ),
            
            Exercise(
                name: "Bodyweight Squat",
                bodyPart: [.squat],
                time: nil
            ),
            
            Exercise(
                name: "Squat Jump",
                bodyPart: [.squat],
                time: nil
            ),
            
            Exercise(
                name: "Walking Lunges",
                bodyPart: [.squat],
                time: nil
            ),
            
            Exercise(
                name: "Tricep Dip",
                bodyPart: [.push, .arms],
                time: nil
            ),
            
            Exercise(
                name: "One Knee Push Up",
                bodyPart: [.push],
                time: nil
            ),
            
//            Exercise(
//                name: "Wall Press",
//                bodyPart: [.push],
//                time: nil
//            ),
            
            Exercise(
                name: "Bent Over Row",
                bodyPart: [.pull, .back],
                time: nil
            ),
            
//            Exercise(
//                name: "Bicep Curl",
//                bodyPart: [.pull, .arms],
//                time: nil
//            ),
            
            Exercise(
                name: "Single Leg Deadlift",
                bodyPart: [.hinge],
                time: nil
            ),
            
            Exercise(
                name: "Romanian Deadlift",
                bodyPart: [.hinge],
                time: nil
            ),
            
            Exercise(
                name: "Glute Bridge",
                bodyPart: [.hinge, .glutes],
                time: nil
            ),
            
            Exercise(
                name: "Plank with Toe Taps",
                bodyPart: [.plank],
                time: nil
            ),
            
            Exercise(
                name: "Plank with Knee Dip",
                bodyPart: [.plank],
                time: nil
            ),
            
            Exercise(
                name: "Plank with Hip Dip",
                bodyPart: [.plank],
                time: nil
            ),
            
            Exercise(
                name: "Plank Row",
                bodyPart: [.plank],
                time: nil
            ),
            
            Exercise(
                name: "Leg Raise",
                bodyPart: [.core],
                time: nil
            ),
            
            Exercise(
                name: "Dead Bug",
                bodyPart: [.core],
                time: nil
            ),
            
            Exercise(
                name: "One Knee Push Up",
                bodyPart: [.chest],
                time: nil
            ),
            
            Exercise(
                name: "Wall Push Up",
                bodyPart: [.chest, .push],
                time: nil
            ),
            
            Exercise(
                name: "Shoulder Toner",
                bodyPart: [.shoulders],
                time: nil
            )
        ]
    }
    
    // MARK: - Insert Dummy Data into SwiftData
    @MainActor
    func insertDummyData(into context: ModelContext) async {
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
            //try context.delete(model: Exercise.self)
            try context.delete(model: DailyMenu.self)
            try context.save()
            print("✅ Cleared all exercises from database")
            print("there's \(exercises.count) left in the database")
        } catch {
            print("❌ Failed to clear exercises: \(error)")
        }
    }
}

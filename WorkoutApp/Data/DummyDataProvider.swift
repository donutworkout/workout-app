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
                name: "Cat-Cow Stretch",
                exerciseType: .mobility,
                bodyPart: .core,
                sets: 2,
                reps: 10,
                time: nil,
                level: .beginner,
                phase: .menstruation,
                imageName: "catcow"
            ),
            
            Exercise(
                name: "Child's Pose",
                exerciseType: .stretch,
                bodyPart: .fullBody,
                sets: 1,
                reps: nil,
                time: 60,
                level: .beginner,
                phase: .menstruation,
                imageName: "childspose"
            ),
            
            Exercise(
                name: "Bird Dog",
                exerciseType: .stability,
                bodyPart: .core,
                sets: 2,
                reps: 8,
                time: nil,
                level: .beginner,
                phase: .menstruation,
                imageName: "birddog"
            ),
            
            Exercise(
                name: "Seated Forward Fold",
                exerciseType: .stretch,
                bodyPart: .lower,
                sets: 1,
                reps: nil,
                time: 45,
                level: .beginner,
                phase: .menstruation,
                imageName: "forwardfold"
            ),
            
            Exercise(
                name: "Gentle Glute Bridge",
                exerciseType: .lightStrength,
                bodyPart: .glutes,
                sets: 2,
                reps: 10,
                time: nil,
                level: .beginner,
                phase: .menstruation,
                imageName: "glutebridge"
            ),
            
            // MARK: - FOLLICULAR PHASE (Building Strength)
            
            Exercise(
                name: "Push-ups",
                exerciseType: .strength,
                bodyPart: .upper,
                sets: 3,
                reps: 12,
                time: nil,
                level: .beginner,
                phase: .follicular,
                imageName: "pushups"
            ),
            
            Exercise(
                name: "Bodyweight Squats",
                exerciseType: .strength,
                bodyPart: .lower,
                sets: 3,
                reps: 15,
                time: nil,
                level: .beginner,
                phase: .follicular,
                imageName: "squats"
            ),
            
            Exercise(
                name: "Plank Hold",
                exerciseType: .isometric,
                bodyPart: .core,
                sets: 3,
                reps: nil,
                time: 30,
                level: .beginner,
                phase: .follicular,
                imageName: "plank"
            ),
            
            Exercise(
                name: "Lunges",
                exerciseType: .strength,
                bodyPart: .lower,
                sets: 3,
                reps: 12,
                time: nil,
                level: .intermediate,
                phase: .follicular,
                imageName: "lunges"
            ),
            
            Exercise(
                name: "Mountain Climbers",
                exerciseType: .dynamic,
                bodyPart: .fullBody,
                sets: 3,
                reps: nil,
                time: 30,
                level: .intermediate,
                phase: .follicular,
                imageName: "mountainclimbers"
            ),
            
            Exercise(
                name: "Shoulder Taps",
                exerciseType: .stability,
                bodyPart: .shoulders,
                sets: 3,
                reps: 20,
                time: nil,
                level: .intermediate,
                phase: .follicular,
                imageName: "shouldertaps"
            ),
            
            Exercise(
                name: "Glute Bridges",
                exerciseType: .strength,
                bodyPart: .glutes,
                sets: 3,
                reps: 15,
                time: nil,
                level: .beginner,
                phase: .follicular,
                imageName: "glutebridge"
            ),
            
            Exercise(
                name: "Superman Hold",
                exerciseType: .hold,
                bodyPart: .back,
                sets: 3,
                reps: nil,
                time: 20,
                level: .beginner,
                phase: .follicular,
                imageName: "superman"
            ),
            
            // MARK: - OVULATION PHASE (Peak Performance)
            
            Exercise(
                name: "Jump Squats",
                exerciseType: .power,
                bodyPart: .lower,
                sets: 4,
                reps: 10,
                time: nil,
                level: .advanced,
                phase: .ovulation,
                imageName: "jumpsquats"
            ),
            
            Exercise(
                name: "Burpees",
                exerciseType: .power,
                bodyPart: .fullBody,
                sets: 4,
                reps: 12,
                time: nil,
                level: .advanced,
                phase: .ovulation,
                imageName: "burpees"
            ),
            
            Exercise(
                name: "Pike Push-ups",
                exerciseType: .strength,
                bodyPart: .shoulders,
                sets: 4,
                reps: 10,
                time: nil,
                level: .advanced,
                phase: .ovulation,
                imageName: "pikepushups"
            ),
            
            Exercise(
                name: "Bulgarian Split Squats",
                exerciseType: .strength,
                bodyPart: .lower,
                sets: 4,
                reps: 12,
                time: nil,
                level: .advanced,
                phase: .ovulation,
                imageName: "bulgariansplits"
            ),
            
            Exercise(
                name: "Explosive Push-ups",
                exerciseType: .power,
                bodyPart: .upper,
                sets: 4,
                reps: 8,
                time: nil,
                level: .advanced,
                phase: .ovulation,
                imageName: "explosivepushups"
            ),
            
            Exercise(
                name: "Box Jumps",
                exerciseType: .power,
                bodyPart: .lower,
                sets: 4,
                reps: 10,
                time: nil,
                level: .advanced,
                phase: .ovulation,
                imageName: "boxjumps"
            ),
            
            Exercise(
                name: "Plank to Down Dog",
                exerciseType: .dynamic,
                bodyPart: .fullBody,
                sets: 3,
                reps: 12,
                time: nil,
                level: .intermediate,
                phase: .ovulation,
                imageName: "plankdowndog"
            ),
            
            // MARK: - LUTEAL PHASE (Moderate Intensity)
            
            Exercise(
                name: "Single-Leg Glute Bridge",
                exerciseType: .strength,
                bodyPart: .glutes,
                sets: 3,
                reps: 10,
                time: nil,
                level: .intermediate,
                phase: .luteal,
                imageName: "singlelegbridge"
            ),
            
            Exercise(
                name: "Tricep Dips",
                exerciseType: .strength,
                bodyPart: .upper,
                sets: 3,
                reps: 12,
                time: nil,
                level: .intermediate,
                phase: .luteal,
                imageName: "tricepdips"
            ),
            
            Exercise(
                name: "Side Plank",
                exerciseType: .isometric,
                bodyPart: .core,
                sets: 3,
                reps: nil,
                time: 30,
                level: .intermediate,
                phase: .luteal,
                imageName: "sideplank"
            ),
            
            Exercise(
                name: "Reverse Lunges",
                exerciseType: .strength,
                bodyPart: .lower,
                sets: 3,
                reps: 12,
                time: nil,
                level: .intermediate,
                phase: .luteal,
                imageName: "reverselunges"
            ),
            
            Exercise(
                name: "Bicycle Crunches",
                exerciseType: .dynamic,
                bodyPart: .core,
                sets: 3,
                reps: 20,
                time: nil,
                level: .intermediate,
                phase: .luteal,
                imageName: "bicyclecrunches"
            ),
            
            Exercise(
                name: "Wall Sit",
                exerciseType: .hold,
                bodyPart: .lower,
                sets: 3,
                reps: nil,
                time: 40,
                level: .beginner,
                phase: .luteal,
                imageName: "wallsit"
            ),
            
            Exercise(
                name: "Shoulder Press (Bodyweight)",
                exerciseType: .compound,
                bodyPart: .shoulders,
                sets: 3,
                reps: 10,
                time: nil,
                level: .intermediate,
                phase: .luteal,
                imageName: "shoulderpress"
            ),
            
            Exercise(
                name: "Dead Bug",
                exerciseType: .control,
                bodyPart: .core,
                sets: 3,
                reps: 12,
                time: nil,
                level: .beginner,
                phase: .luteal,
                imageName: "deadbug"
            ),
            
            // MARK: - ADDITIONAL EXERCISES (More Variety)
            
            Exercise(
                name: "Diamond Push-ups",
                exerciseType: .strength,
                bodyPart: .upper,
                sets: 3,
                reps: 10,
                time: nil,
                level: .intermediate,
                phase: .follicular,
                imageName: "diamondpushups"
            ),
            
            Exercise(
                name: "Calf Raises",
                exerciseType: .isolation,
                bodyPart: .lower,
                sets: 3,
                reps: 20,
                time: nil,
                level: .beginner,
                phase: .follicular,
                imageName: "calfraises"
            ),
            
            Exercise(
                name: "High Knees",
                exerciseType: .endurance,
                bodyPart: .fullBody,
                sets: 3,
                reps: nil,
                time: 30,
                level: .beginner,
                phase: .follicular,
                imageName: "highknees"
            ),
            
            Exercise(
                name: "Russian Twists",
                exerciseType: .dynamic,
                bodyPart: .core,
                sets: 3,
                reps: 20,
                time: nil,
                level: .intermediate,
                phase: .luteal,
                imageName: "russiantwists"
            ),
            
            Exercise(
                name: "Jumping Jacks",
                exerciseType: .endurance,
                bodyPart: .fullBody,
                sets: 3,
                reps: nil,
                time: 45,
                level: .beginner,
                phase: .follicular,
                imageName: "jumpingjacks"
            ),
            
            Exercise(
                name: "Inchworms",
                exerciseType: .mobility,
                bodyPart: .fullBody,
                sets: 2,
                reps: 10,
                time: nil,
                level: .intermediate,
                phase: .follicular,
                imageName: "inchworms"
            ),
            
            Exercise(
                name: "Bear Crawl",
                exerciseType: .dynamic,
                bodyPart: .fullBody,
                sets: 3,
                reps: nil,
                time: 30,
                level: .intermediate,
                phase: .ovulation,
                imageName: "bearcrawl"
            ),
            
            Exercise(
                name: "Forearm Plank",
                exerciseType: .isometric,
                bodyPart: .core,
                sets: 3,
                reps: nil,
                time: 45,
                level: .intermediate,
                phase: .follicular,
                imageName: "forearmplank"
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

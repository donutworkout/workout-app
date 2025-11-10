//
//  ExerciseRepository.swift
//  WorkoutApp
//

import Foundation
import SwiftData

class ExerciseRepository {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Get Exercises with Filters (FIXED for SwiftData)
    func getExercises(
        forLevel level: WorkoutLevel,
        phase: MenstrualPhase,
        bodyPart: BodyPart? = nil,
        count: Int = 5
    ) -> [Exercise] {
        
        print("\n🔍 Fetching exercises:")
        print("  Level: \(level.rawValue)")
        print("  Phase: \(phase.rawValue)")
        print("  Body Part: \(bodyPart?.rawValue ?? "Any")")
        
        // SIMPLE FETCH: Get ALL exercises, then filter in Swift
        let descriptor = FetchDescriptor<Exercise>()
        
        guard let allExercises = try? context.fetch(descriptor) else {
            print("  ❌ Failed to fetch exercises")
            return []
        }
        
        print("  📦 Total in database: \(allExercises.count)")
        
        // MANUAL FILTERING (this works perfectly with enums!)
        var filtered = allExercises
        
        //  Filter by level + bodyPart
        switch level {
        case .beginner, .intermediate:
            // Beginners only get full-body exercises
            filtered = filtered.filter { exercise in
                exercise.bodyPart.contains(.fullBody)
            }
            print("  🟢 Beginner filter: \(filtered.count)")
            
        case .advanced:
            // Advanced: isolate specific muscle group (strict)
            if let bodyPart = bodyPart {
                filtered = filtered.filter { exercise in
                    exercise.bodyPart.contains(.upperPull) || exercise.bodyPart.contains(.upperPush)
                }
                print("  🔴 Advanced strict \(bodyPart.rawValue) filter: \(filtered.count)")
            }
        }
        
        // Filter by exercise types
//        if let types = exerciseTypes, !types.isEmpty {
//            filtered = filtered.filter { exercise in
//                types.contains(exercise.exerciseType)
//            }
//            print("  ✓ After type filter: \(filtered.count)")
//        }
        
        // Select balanced
        let selected = selectBalancedExercises(from: filtered, count: count)
        print("  ✅ Final selected: \(selected.count)\n")
        
        return selected
    }
    
    // MARK: - Balanced Selection
    private func selectBalancedExercises(from exercises: [Exercise], count: Int) -> [Exercise] {
        guard exercises.count > count else { return exercises }
        
        var selected: [Exercise] = []
        var remaining = exercises
        var usedBodyParts: Set<BodyPart> = []
        
        while selected.count < count && !remaining.isEmpty {
            // Try new body part
            if let exercise = remaining.first(where: { ex in
                        // Check: Does exercise have a bodyPart that is NOT yet used?
                        ex.bodyPart.contains { !usedBodyParts.contains($0) }
            }) {
                selected.append(exercise)
                
                // Add ALL its body parts to used set
                for part in exercise.bodyPart {
                    usedBodyParts.insert(part)
                }
                
                remaining.removeAll { $0.id == exercise.id }
            }
            
            // Just pick next
            else {
                let exercise = remaining.removeFirst()
                selected.append(exercise)
                
                for part in exercise.bodyPart {
                    usedBodyParts.insert(part)
                }
            }
        }
        
        return selected
    }
    
    // MARK: - Get All
    func getAllExercises() -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>()
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Get Count
    func getExerciseCount() -> Int {
        let descriptor = FetchDescriptor<Exercise>()
        return (try? context.fetchCount(descriptor)) ?? 0
    }
}

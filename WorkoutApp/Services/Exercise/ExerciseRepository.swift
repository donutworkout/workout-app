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
        exerciseTypes: [ExerciseType]? = nil,
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
        
        // Filter by level
        filtered = filtered.filter { exercise in
            exercise.level == level || exercise.level == .beginner
        }
        print("  ✓ After level filter: \(filtered.count)")
        
        // Filter by phase
        filtered = filtered.filter { exercise in
            exercise.phase == phase || isExerciseSuitableForPhase(exercise, targetPhase: phase)
        }
        print("  ✓ After phase filter: \(filtered.count)")
        
        // Filter by body part
        if let bodyPart = bodyPart {
            filtered = filtered.filter { exercise in
                exercise.bodyPart == bodyPart || exercise.bodyPart == .fullBody
            }
            print("  ✓ After body part filter: \(filtered.count)")
        }
        
        // Filter by exercise types
        if let types = exerciseTypes, !types.isEmpty {
            filtered = filtered.filter { exercise in
                types.contains(exercise.exerciseType)
            }
            print("  ✓ After type filter: \(filtered.count)")
        }
        
        // Select balanced
        let selected = selectBalancedExercises(from: filtered, count: count)
        print("  ✅ Final selected: \(selected.count)\n")
        
        return selected
    }
    
    // MARK: - Phase Suitability Check
    private func isExerciseSuitableForPhase(_ exercise: Exercise, targetPhase: MenstrualPhase) -> Bool {
        switch targetPhase {
        case .menstruation:
            // Only gentle during menstruation
            return exercise.exerciseType == .mobility ||
                   exercise.exerciseType == .stretch ||
                   exercise.exerciseType == .stability ||
                   exercise.exerciseType == .lightStrength
            
        case .follicular:
            // Can do follicular or ovulation
            return exercise.phase == .follicular || exercise.phase == .ovulation
            
        case .ovulation:
            // Peak - anything except menstrual
            return exercise.phase != .menstruation
            
        case .luteal:
            // Moderate
            return exercise.phase == .luteal ||
                   exercise.phase == .follicular ||
                   exercise.exerciseType == .strength ||
                   exercise.exerciseType == .compound
        }
    }
    
    // MARK: - Balanced Selection
    private func selectBalancedExercises(from exercises: [Exercise], count: Int) -> [Exercise] {
        guard exercises.count > count else { return exercises }
        
        var selected: [Exercise] = []
        var remaining = exercises
        var usedBodyParts: Set<BodyPart> = []
        var usedTypes: Set<ExerciseType> = []
        
        while selected.count < count && !remaining.isEmpty {
            // Try new body part
            if let exercise = remaining.first(where: { !usedBodyParts.contains($0.bodyPart) }) {
                selected.append(exercise)
                usedBodyParts.insert(exercise.bodyPart)
                usedTypes.insert(exercise.exerciseType)
                remaining.removeAll { $0.id == exercise.id }
            }
            // Try new type
            else if let exercise = remaining.first(where: { !usedTypes.contains($0.exerciseType) }) {
                selected.append(exercise)
                usedTypes.insert(exercise.exerciseType)
                remaining.removeAll { $0.id == exercise.id }
            }
            // Just pick next
            else {
                let exercise = remaining.removeFirst()
                selected.append(exercise)
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

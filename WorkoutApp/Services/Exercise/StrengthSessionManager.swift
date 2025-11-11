//
//  StrengthSessionManager.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 10/11/25.
//

import Foundation
import Combine

class StrengthSessionManager: ObservableObject {
    static let shared = StrengthSessionManager()
    
    @Published var exercises: [Exercise] = []
    @Published var currentExerciseIndex: Int = 0
    @Published var isWorkoutComplete: Bool = false
    
    private init() {} 
    
    var currentExercise: Exercise? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    var hasNextExercise: Bool {
        return currentExerciseIndex < exercises.count - 1
    }
    
    var currentPage: Int {
        return currentExerciseIndex + 1
    }
    
    var totalPages: Int {
        return exercises.count
    }
    
    func startWorkout(with exercises: [Exercise]) {
        self.exercises = exercises
        self.currentExerciseIndex = 0
        self.isWorkoutComplete = false
    }
    
    func moveToNextExercise() {
        if hasNextExercise {
            currentExerciseIndex += 1
        } else {
            isWorkoutComplete = true
        }
    }
    
    func reset() {
        exercises = []
        currentExerciseIndex = 0
        isWorkoutComplete = false
    }
}

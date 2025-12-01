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
    @Published var currentSetNumber: Int = 1
    @Published var isWorkoutComplete: Bool = false
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    
    private init() {} 
    
    var currentExercise: Exercise? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    var nextExercise: Exercise? {
        let nextIndex = currentExerciseIndex + 1
        guard nextIndex < exercises.count else { return nil }
        return exercises[nextIndex]
    }
    
    var hasNextExercise: Bool {
        return currentExerciseIndex < exercises.count - 1
    }
    
    var hasMoreSets: Bool {
        guard let exercise = currentExercise else { return false }
        
        // Only apply sets logic if exercise has a time duration
        guard let time = exercise.time, time > 0 else {
            return false  // Rep-based exercises don't have multiple sets
        }
        
        let totalSets = exercise.sets ?? 1
        return currentSetNumber < totalSets
    }
    
    var currentPage: Int {
        return currentExerciseIndex + 1
    }
    
    func startWorkout(with exercises: [Exercise]) {
        self.exercises = exercises
        self.currentExerciseIndex = 0
        self.isWorkoutComplete = false
    }
    
    func prepareWorkout(with exercises: [Exercise]) {
        self.exercises = exercises
        self.currentExerciseIndex = 0
        self.isWorkoutComplete = false
        self.isPaused = false
        self.isRunning = false
    }
    
    func beginWorkout() {
        guard !isRunning else { return }
        isRunning = true
        isPaused = false
    }
    
    func moveToNextExercise() {
        if hasMoreSets {
            currentSetNumber += 1
        } else {
            if hasNextExercise {
                currentExerciseIndex += 1
                currentSetNumber = 1
            } else {
                isWorkoutComplete = true
            }
        }
    }
    
    func pause() {
        guard isRunning else { return }
        isPaused = true
    }
    
    func resume() {
        guard isRunning else { return }
        isPaused = false
    }
    
    func reset() {
        exercises = []
        currentExerciseIndex = 0
        isWorkoutComplete = false
        isRunning = false
        isPaused = false
    }
}

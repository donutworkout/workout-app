//
//  StreakManager.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 24/11/25.
//

import Foundation
import SwiftData

class StreakManager {
    static let shared = StreakManager()
    private init() {}
    
    func updateStreak(context: ModelContext) {
        let descriptor = FetchDescriptor<Streak>()
        let streaks = try? context.fetch(descriptor)
        
        let streak: Streak
        if let existing = streaks?.first {
            streak = existing
        } else {
            streak = Streak()
            context.insert(streak)
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastWorkout = calendar.startOfDay(for: streak.lastWorkoutDate)
        let daysDifference = calendar.dateComponents([.day], from: lastWorkout, to: today).day ?? 0
        
        // ✅ Check if new month - reset monthly counter
        let currentMonth = calendar.component(.month, from: Date())
        if currentMonth != streak.lastMonthRecorded {
            streak.workoutsThisMonth = 0
            streak.lastMonthRecorded = currentMonth
            print("📅 New month! Reset workout count")
        }
        
        if daysDifference == 0 {
            print("✅ Already completed workout today")
        } else if daysDifference == 1 {
            // Consecutive day
            streak.currentStreak += 1
            streak.lastWorkoutDate = Date()
            streak.workoutsThisMonth += 1  // ✅ Increment monthly count
            
            if streak.currentStreak > streak.longestStreak {
                streak.longestStreak = streak.currentStreak
            }
            print("🔥 Streak: \(streak.currentStreak) | Month: \(streak.workoutsThisMonth)")
        } else {
            // Streak broken
            streak.currentStreak = 1
            streak.lastWorkoutDate = Date()
            streak.workoutsThisMonth += 1  // ✅ Still count for monthly goal
            print("💔 Streak reset | Month: \(streak.workoutsThisMonth)")
        }
        
        try? context.save()
    }
    
    // ✅ Get monthly goal based on user's workout schedule
    func getMonthlyGoal(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<UserWorkout>()
        guard let userWorkout = try? context.fetch(descriptor).first else {
            return 12 // Default goal
        }
        
        // Count how many workout days per week
        let workoutDays = userWorkout.workoutDaysPreference.filter { $0 != .flexible }.count
        
        // Approximate: 4 weeks per month
        return workoutDays * 4
    }
    
    // ✅ Get progress
    func getMonthlyProgress(context: ModelContext) -> (completed: Int, goal: Int, percentage: Double) {
        let descriptor = FetchDescriptor<Streak>()
        guard let streak = try? context.fetch(descriptor).first else {
            return (0, getMonthlyGoal(context: context), 0.0)
        }
        
        // Check if we're in the same month
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let completed = (currentMonth == streak.lastMonthRecorded) ? streak.workoutsThisMonth : 0
        
        let goal = getMonthlyGoal(context: context)
        let percentage = min(Double(completed) / Double(goal), 1.0)
        
        return (completed, goal, percentage)
    }
}



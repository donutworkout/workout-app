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
        let isNewStreak: Bool
        if let existing = streaks?.first {
            streak = existing
            isNewStreak = false
        } else {
            streak = Streak()
            context.insert(streak)
            isNewStreak = true
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
        
        print("Current streak: \(streak.currentStreak)")
        print("Last workout date: \(streak.lastWorkoutDate)")
        
        if isNewStreak {
            streak.currentStreak = 1
            streak.longestStreak = 1
            streak.lastWorkoutDate = Date()
            streak.workoutsThisMonth = 1
            print("🎉 First workout! Streak started at 1")
        } else if daysDifference == 0 {
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
        } else if daysDifference > 1 {
            if wereMissedDaysRestDays(from: lastWorkout, to: today, context: context) {
                streak.lastWorkoutDate = Date()
                streak.workoutsThisMonth += 1
                print("😌 Rest days in between - streak maintained at \(streak.currentStreak)")
            } else {
                // Streak broken
                streak.currentStreak = 0
                streak.lastWorkoutDate = Date()
                streak.workoutsThisMonth += 1  // ✅ Still count for monthly goal
                print("💔 Streak reset | Month: \(streak.workoutsThisMonth)")
            }
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
    
    private func wereMissedDaysRestDays(from lastDate: Date, to currentDate: Date, context: ModelContext) -> Bool {
        let calendar = Calendar.current
        let descriptor = FetchDescriptor<DailyMenu>()
        guard let menus = try? context.fetch(descriptor) else {
            return false
        }
        
        var date = calendar.date(byAdding: .day, value: 1, to: lastDate)!
        
        while date < currentDate {
            // Check if this date had a workout day scheduled
            let dayMenu = menus.first { menu in
                calendar.isDate(menu.date, inSameDayAs: date)
            }
            
            // If it was a workout day (not rest), streak should break
            if let menu = dayMenu, case .rest = menu.category {
                return false  // Found a workout day that was missed
            }
            
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return true  // All missed days were rest days
    }
}



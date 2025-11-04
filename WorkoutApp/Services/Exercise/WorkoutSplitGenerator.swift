//
//  WorkoutSplitGenerator.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 03/11/25.
//

import Foundation

class WorkoutSplitGenerator {
    
    func generateWeeklySplit(
        chosenDays: [WorkoutDayPreference],
        level: WorkoutLevel,
        userCycle: UserCycle,
        //hasCramps: Bool
        
    ) -> [Int: MenuCategory] {
        
        let dayNumbers = chosenDays.compactMap { $0.toDayNumber() }.sorted()
        let totalDays = dayNumbers.count
        
        // 1. create base balanced split (50/50)
        var baseSplit: [MenuCategory] = []
        for i in 0..<totalDays {
            baseSplit.append(i % 2 == 0 ? .strength : .cardio)
        }
        
        // 2. adjust for level
        baseSplit = adjustForLevel(split: baseSplit, level: level)
        
        let hasCramps = userCycle.hasCrampsToday
        
        // 3. map to calendar days & check for period
        var schedule: [Int: MenuCategory] = [:]
        
        for (index, dayNumber) in dayNumbers.enumerated() {
            
            // get the actual date for this workout day
            let workoutDate = getDateForDayOfWeek(dayNumber: dayNumber)
            
            // check what cycle day this workout falls on
            let cycleDay = getCycleDayForDate(
                date: workoutDate,
                lastPeriodStart: userCycle.cycleStartDate,
                cycleLength: userCycle.cycleLength
            )
            
            // check if this is during cramps
            let isDuringCramps = cycleDay >= 1 && cycleDay <= 3
            let shouldRest = isDuringCramps && hasCramps
            
            if isDuringCramps && hasCramps {
                schedule[dayNumber] = .rest
            } else {
                schedule[dayNumber] = baseSplit[index]
            }
        }
        
        // fill remaining days as rest
        for day in 1...7 {
            if schedule[day] == nil {
                schedule[day] = .rest
            }
        }
        
        
        return schedule
    }
    
    private func adjustForLevel(split: [MenuCategory], level: WorkoutLevel) -> [MenuCategory] {
        var adjusted = split
        
        // Advanced users with 5+ days get extra strength
        if level == .advanced && split.count >= 5 {
            if let lastCardioIndex = adjusted.lastIndex(of: .cardio) {
                adjusted[lastCardioIndex] = .strength
                print("Adjusted for advanced level: added extra strength day")
            }
        }
        
        return adjusted
    }
    
    // MARK: - Get Cycle Day for Specific Date
    private func getCycleDayForDate(
        date: Date,
        lastPeriodStart: Date,
        cycleLength: Int
    ) -> Int {
        let calendar = Calendar.current
        
        let daysSinceStart = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: lastPeriodStart),
            to: calendar.startOfDay(for: date)
        ).day ?? 0
        
        // Handle if date is before last period start (shouldn't happen but safety)
        if daysSinceStart < 0 {
            // Go back one cycle
            let adjustedDays = cycleLength + daysSinceStart
            return max(1, adjustedDays % cycleLength)
        }
        
        // Calculate cycle day (1-28)
        let cycleDay = (daysSinceStart % cycleLength) + 1
        return cycleDay
    }
    
    // MARK: - Get Date for Day of Week
    private func getDateForDayOfWeek(dayNumber: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        // Get current day of week (1=Monday, 7=Sunday)
        let currentWeekday = calendar.component(.weekday, from: today)
        let currentDayNumber = currentWeekday == 1 ? 7 : currentWeekday - 1
        
        // Calculate difference
        let daysDifference = dayNumber - currentDayNumber
        
        // Get that date
        return calendar.date(byAdding: .day, value: daysDifference, to: today) ?? today
    }
    
    // MARK: - Helpers
    func getDayName(_ day: Int) -> String {
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return days[day - 1]
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }
}



extension WorkoutDayPreference {
    func toDayNumber() -> Int? {
        switch self {
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        case .sunday: return 7
        case .flexible: return nil
        }
    }
}

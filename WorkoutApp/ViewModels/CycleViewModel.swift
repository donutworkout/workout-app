//
//  CycleViewModel.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 05/11/25.
//

import Foundation
import SwiftUI

@MainActor
final class CycleViewModel: ObservableObject {
    @Published var selectedDayIndex: Int = 0
    @Published var phasesForWeek: [(date: Date, phase: MenstrualPhase)] = []
    
    private var userCycle: UserCycle
    
    init(userCycle: UserCycle) {
        self.userCycle = userCycle
        
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        self.selectedDayIndex = weekday == 1 ? 6 : weekday - 2
        
        generatePhasesForWeek()
    }
    
    func generatePhasesForWeek() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get the start of this week (Sunday)
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return
        }
        
        // Build 7 days (Sun-Sat)
        phasesForWeek = (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: weekStart) else {
                return nil
            }
            
            // FIXED: Calculate phase for THIS SPECIFIC DATE, not today
            let daysSinceStart = calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: userCycle.cycleStartDate),
                to: calendar.startOfDay(for: date)
            ).day ?? 0
            
            let currentDayInCycle = (daysSinceStart % userCycle.cycleLength) + 1
            
            let phase = CyclePhaseCalculator.phaseForDay(
                currentDayInCycle,
                cycleLength: userCycle.cycleLength,
                periodDuration: userCycle.menstrualDuration
            )
            
            return (date, phase)
        }
    }
    
    func phase(for index: Int) -> MenstrualPhase? {
        guard index >= 0 && index < phasesForWeek.count else { return nil }
        return phasesForWeek[index].phase
    }
    
    func updateCycle(_ newCycle: UserCycle) {
        self.userCycle = newCycle
    }
    
    func dateForSelectedDay() -> Date {
        guard selectedDayIndex >= 0 && selectedDayIndex < phasesForWeek.count else {
            return Date()
        }
        return phasesForWeek[selectedDayIndex].date
    }
}


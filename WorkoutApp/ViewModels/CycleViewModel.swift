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
        print("🟢🟢🟢 generatePhasesForWeek() CALLED 🟢🟢🟢")
        print("🟢 userCycle.cycleStartDate: \(userCycle.cycleStartDate)")
        print("🟢 userCycle.cycleLength: \(userCycle.cycleLength)")
        print("🟢 userCycle.menstrualDuration: \(userCycle.menstrualDuration)")
        
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        
        print("🟢 Today: \(today)")
        print("🟢 Weekday component: \(weekday)")
        
        let daysToMonday = weekday == 1 ? -6 : -(weekday - 2)
        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today) else {
            print("❌ Failed to calculate Monday")
            return
        }
        
        print("🟢 Monday calculated: \(monday)")
        
        // Rest of your code...
        phasesForWeek = (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else {
                return nil
            }
            
            let daysSinceStart = calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: userCycle.cycleStartDate),
                to: calendar.startOfDay(for: date)
            ).day ?? 0
            
            let currentDayInCycle = (daysSinceStart % userCycle.cycleLength) + 1
            
            print("🟢 Offset \(offset): date=\(date), daysSinceStart=\(daysSinceStart), cycleDay=\(currentDayInCycle)")
            
            let phase = CyclePhaseCalculator.phaseForDay(
                currentDayInCycle,
                cycleLength: userCycle.cycleLength,
                periodDuration: userCycle.menstrualDuration
            )
            
            print("🟢 Calculated phase: \(phase)")
            
            return (date, phase)
        }
        
        print("🟢 generatePhasesForWeek() COMPLETE - generated \(phasesForWeek.count) phases")
    }

    
    func phase(for index: Int) -> MenstrualPhase? {
        guard index >= 0 && index < phasesForWeek.count else { return nil }
        return phasesForWeek[index].phase
    }
    
    func updateCycle(_ newCycle: UserCycle) {
        self.userCycle = newCycle
        generatePhasesForWeek()
        
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        self.selectedDayIndex = weekday == 1 ? 6 : weekday - 2
    }
    
    func dateForSelectedDay() -> Date {
        guard selectedDayIndex >= 0 && selectedDayIndex < phasesForWeek.count else {
            return Date()
        }
        return phasesForWeek[selectedDayIndex].date
    }
}


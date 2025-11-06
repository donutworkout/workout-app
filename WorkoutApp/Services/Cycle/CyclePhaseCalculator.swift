//
//  CyclePhaseCalculator.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 29/10/25.
//

import Foundation

class CyclePhaseCalculator {
    
    static func calculateCurrentPhase(
        lastPeriodStart: Date,
        cycleLength: Int = 28,
        menstrualDuration: Int = 5
        
    ) -> MenstrualPhase {
        
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfLastPeriod = calendar.startOfDay(for: lastPeriodStart)

        let daysSinceStart = calendar.dateComponents([.day], from: startOfLastPeriod, to: startOfToday).day ?? 0
        
        let currentDayInCycle = (daysSinceStart % cycleLength) + 1
        
        print("🩸 Days since last period: \(daysSinceStart) → current cycle day: \(currentDayInCycle)")
        
        return phaseForDay(currentDayInCycle, cycleLength: cycleLength, periodDuration: menstrualDuration)
    }
    
    static func phaseForDay(_ day: Int, cycleLength: Int = 28, periodDuration: Int = 5) -> MenstrualPhase {
        // Menstruation: Days 1-5 (or custom period duration)
        if day >= 1 && day <= periodDuration {
            print("day of cycle : \(String(day))")
            return .menstruation
        }
        
        // Ovulation: Around day 14 (can vary by cycle length)
        let ovulationDay = cycleLength / 2
        let ovulationWindow = (ovulationDay - 1)...(ovulationDay + 1)
        if ovulationWindow.contains(day) {
            return .ovulation
        }
        
        // Follicular: Between period and ovulation
        if day > periodDuration && day < ovulationDay - 1 {
            return .follicular
        }
        
        // Luteal: After ovulation until next period
        return .luteal

    }
    
    /// Calculate next phase change date
    static func nextPhaseChangeDate(
        lastPeriodStart: Date,
        currentPhase: MenstrualPhase,
        cycleLength: Int = 28,
        periodDuration: Int = 5
    ) -> Date? {
        let calendar = Calendar.current
        let today = Date()
        
        let daysSinceStart = calendar.dateComponents([.day], from: lastPeriodStart, to: today).day ?? 0
        let currentDayInCycle = (daysSinceStart % cycleLength) + 1
        
        var nextPhaseDay: Int
        
        switch currentPhase {
        case .menstruation:
            nextPhaseDay = periodDuration + 1
        case .follicular:
            nextPhaseDay = (cycleLength / 2) - 1
        case .ovulation:
            nextPhaseDay = (cycleLength / 2) + 2
        case .luteal:
            nextPhaseDay = cycleLength + 1 // Next period
        }
        
        let daysUntilNextPhase = nextPhaseDay - currentDayInCycle
        return calendar.date(byAdding: .day, value: daysUntilNextPhase, to: today)
    }
    
    /// Predict next period date
    static func predictNextPeriod(lastPeriodStart: Date, cycleLength: Int = 28) -> Date? {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: cycleLength, to: lastPeriodStart)
    }
    
    
    static func getPhaseDatesForCycle(
            lastPeriodStart: Date,
            cycleLength: Int = 28,
            periodDuration: Int = 5
    ) -> [(phase: MenstrualPhase, startDate: Date, endDate: Date)] {
        let calendar = Calendar.current
        var phases: [(MenstrualPhase, Date, Date)] = []
        
        // Menstruation
        if let menstruationEnd = calendar.date(byAdding: .day, value: periodDuration - 1, to: lastPeriodStart) {
            phases.append((.menstruation, lastPeriodStart, menstruationEnd))
        }
        
        // Follicular
        if let follicularStart = calendar.date(byAdding: .day, value: periodDuration, to: lastPeriodStart),
           let follicularEnd = calendar.date(byAdding: .day, value: (cycleLength / 2) - 2, to: lastPeriodStart) {
            phases.append((.follicular, follicularStart, follicularEnd))
        }
        
        // Ovulation
        if let ovulationStart = calendar.date(byAdding: .day, value: (cycleLength / 2) - 1, to: lastPeriodStart),
           let ovulationEnd = calendar.date(byAdding: .day, value: (cycleLength / 2) + 1, to: lastPeriodStart) {
            phases.append((.ovulation, ovulationStart, ovulationEnd))
        }
        
        // Luteal
        if let lutealStart = calendar.date(byAdding: .day, value: (cycleLength / 2) + 2, to: lastPeriodStart),
           let lutealEnd = calendar.date(byAdding: .day, value: cycleLength - 1, to: lastPeriodStart) {
            phases.append((.luteal, lutealStart, lutealEnd))
        }
        
        return phases
    }
        
    
}

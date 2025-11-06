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
    
    private let userCycle: UserCycle
    
    init(userCycle: UserCycle) {
        self.userCycle = userCycle
        generatePhasesForWeek()
    }
    
    func generatePhasesForWeek() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Build 7 days starting today (Mon–Sun pattern)
        phasesForWeek = (0..<7).compactMap { offset in
            if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                let phase = CyclePhaseCalculator.calculateCurrentPhase(
                    lastPeriodStart: userCycle.cycleStartDate,
                    cycleLength: userCycle.cycleLength,
                    menstrualDuration: userCycle.menstrualDuration
                )
                return (date, phase)
            }
            return nil
        }
    }
    
    func phase(for index: Int) -> MenstrualPhase? {
        guard index >= 0 && index < phasesForWeek.count else { return nil }
        return phasesForWeek[index].phase
    }
}


//
//  CycleStateManager.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 29/10/25.
//

import Foundation

@MainActor
final class CycleStateManager {
    @Published private(set) var currentPhase: MenstrualPhase?
    //@Published private var nextPhaseDate: Date?
    
    private let calculator = CyclePhaseCalculator()
    private let userCycle: UserCycle
    
    init(userCycle: UserCycle) {
        self.userCycle = userCycle
        
    }
    
    func updatePhase() {
        let lastStart = userCycle.cycleStartDate
        
        currentPhase = CyclePhaseCalculator.calculateCurrentPhase(lastPeriodStart: lastStart)
    }
    
//    // Optional: call this when user logs new period start
//    func updateLastPeriodStart(to newDate: Date) {
//        userProfile.lastPeriodStart = newDate
//        updatePhase()
//    }
}

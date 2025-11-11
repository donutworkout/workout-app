//
//  MenuViewModel.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 06/11/25.
//

import Foundation
import SwiftData

@MainActor
class MenuViewModel: ObservableObject {
    @Published var weeklyMenu: [DailyMenu] = []
    @Published var isLoading = false
    
    private let modelContext: ModelContext
    private var generator: WorkoutMenuGenerator
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.generator = WorkoutMenuGenerator(context: modelContext)
    }
    
    // MARK: - Generate Weekly Menu
    func generateWeeklyMenu(
        userCycle: UserCycle,
        userLevel: WorkoutLevel,
        chosenDays: [WorkoutDayPreference]
    ) async {
        isLoading = true
        
        weeklyMenu = generator.generateWeeklyMenu(
            level: userLevel,
            chosenDays: chosenDays,
            userCycle: userCycle,
            strengthType: .bodyWeight // Default, user can switch in detail view
        )
        
        isLoading = false
    }
    
    // MARK: - Get Menu for Specific Day
    func getMenu(for dayNumber: Int) -> DailyMenu? {
        return weeklyMenu.first { $0.dayNumber == dayNumber }
    }
    
    // MARK: - Get Menu for Date
    func getMenuForDate(_ date: Date) -> DailyMenu? {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let dayNumber = weekday == 1 ? 7 : weekday - 1 // Convert to Monday=1 system
        return getMenu(for: dayNumber)
    }
}

//
//  WorkoutViewModel.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 14/10/25.
//

import Foundation
import SwiftData

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var bodyweightWorkouts: [Exercise] = []
    @Published var gymWorkouts: [Exercise] = []
    @Published var cardioWorkouts: DailyMenu?
    
    @Published var weeklyMenus: [DailyMenu] = []
    @Published var selectedMenu: DailyMenu? // for selected day detail
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let modelContext: ModelContext
    private let exerciseRepo: ExerciseRepository
    private let generator: WorkoutMenuGenerator
    
    var hasWorkouts: Bool {
        !bodyweightWorkouts.isEmpty || !gymWorkouts.isEmpty
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.exerciseRepo = ExerciseRepository(context: modelContext)
        self.generator = WorkoutMenuGenerator(context: modelContext)
    }
    
    func generateWeeklyWorkoutPlan(
        userCycle: UserCycle,
        userLevel: WorkoutLevel,
        chosenDays: [WorkoutDayPreference],
        strengthType: StrengthType
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Generate full 7-day plan based on the user’s chosen days & split
            let menus = generator.generateWeeklyMenu(
                level: userLevel,
                chosenDays: chosenDays,
                userCycle: userCycle,
                strengthType: strengthType
            )
            
            await MainActor.run {
                self.weeklyMenus = menus
            }
            
        } catch {
            errorMessage = "Failed to generate weekly plan: \(error.localizedDescription)"
            print("❌ Error: \(error)")
        }
        
        isLoading = false
    }

    
    func generateStrengthWorkoutsForDay(
        dayNumber: Int,
        dayName: String,
        date: Date,
        userCycle: UserCycle,
        userLevel: WorkoutLevel
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            
            let currentPhase = CyclePhaseCalculator.calculateCurrentPhase(
                lastPeriodStart: userCycle.cycleStartDate,
                menstrualDuration: userCycle.menstrualDuration
            )
            
            let dayNumber = getTodaysDayNumber()
            let dayName = getDayName(dayNumber)
            
            async let bodyweightMenu = generator.generateStrengthMenu(
                dayNumber: dayNumber,
                dayName: dayName,
                date: date,
                level: userLevel,
                phase: currentPhase,
                strengthType: .bodyWeight,
                strengthDayIndex: 0
            )
            
            async let gymMenu = generator.generateStrengthMenu(
                dayNumber: dayNumber,
                dayName: dayName,
                date: date,
                level: userLevel,
                phase: currentPhase,
                strengthType: .gym,
                strengthDayIndex: 0
            )
            
            let (bwMenu, gMenu) = try await (bodyweightMenu, gymMenu)
              
            await MainActor.run {
                self.bodyweightWorkouts = bwMenu.strengthExercises ?? []
                self.gymWorkouts = gMenu.strengthExercises ?? []
            }
            
        } catch {
            errorMessage = "Failed to generate workouts: \(error.localizedDescription)"
            print("❌ Error: \(error)")
        }
        
        isLoading = false
    }
    
}

extension WorkoutViewModel {
    
    private func getTodaysDayNumber() -> Int {
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        return weekday == 1 ? 7 : weekday - 1 // Convert to Monday=1 system
    }
    
    private func getDayName(_ day: Int) -> String {
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return days[day - 1]
    }
}

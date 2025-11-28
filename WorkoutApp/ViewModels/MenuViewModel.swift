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
    
    private var lastWorkoutLevel: WorkoutLevel?
    private var lastWorkoutDays: [WorkoutDayPreference]?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.generator = WorkoutMenuGenerator(context: modelContext)
        
        DummyExerciseProvider.shared.insertDummyData(into: modelContext)
        
        let existingMenus = fetchMenusForCurrentWeek()
        if !existingMenus.isEmpty {
            self.weeklyMenu = existingMenus
            print("📥 Loaded \(existingMenus.count) existing menus on init")
        }
    }
    
    func generateWeeklyMenuIfNeeded(
        userCycle: UserCycle,
        userLevel: WorkoutLevel,
        chosenDays: [WorkoutDayPreference],
        forceProfileCheck: Bool = false
    ) async {
        loadSavedMenus()
        
        if weeklyMenu.isEmpty {
                print("🎯 No menus for this week → first time generate")
                lastWorkoutLevel = userLevel
                lastWorkoutDays  = chosenDays
                await deleteMenusForCurrentWeek()
                await generateWeeklyMenu(userCycle: userCycle, userLevel: userLevel, chosenDays: chosenDays)
                return
            }

            // Kalau tidak dipaksa cek, dan level/days belum pernah diset → jadikan baseline, jangan regenerate
        if !forceProfileCheck && lastWorkoutLevel == nil && lastWorkoutDays == nil {
            print("🧩 Set baseline profile without regenerating")
            lastWorkoutLevel = userLevel
            lastWorkoutDays  = chosenDays
            return
        }

            // Hitung perubahan profil
            let hasLevelChanged = lastWorkoutLevel != userLevel
            let hasDaysChanged  = lastWorkoutDays != chosenDays
            let hasProfileChanged = hasLevelChanged || hasDaysChanged

            print("🔍 Profile check:")
            print("   Level changed: \(hasLevelChanged)")
            print("   Days changed : \(hasDaysChanged)")

            guard hasProfileChanged else {
                print("⚡ Profile unchanged, keep existing menus")
                return
            }

            print("🔄 Profile changed (or force check), regenerating weekly menu…")
            lastWorkoutLevel = userLevel
            lastWorkoutDays  = chosenDays

            await deleteMenusForCurrentWeek()
            await generateWeeklyMenu(userCycle: userCycle, userLevel: userLevel, chosenDays: chosenDays)
    }

    // MARK: - New delete method (add this)
    private func deleteMenusForCurrentWeek() async {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = weekday == 1 ? -6 : -(weekday - 2)
        
        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today),
              let nextMonday = calendar.date(byAdding: .day, value: 7, to: monday) else {
            return
        }
        
        let descriptor = FetchDescriptor<DailyMenu>(
                predicate: #Predicate { menu in
                    menu.date >= monday && menu.date < nextMonday
                }
        )
        
        do {
            let existingMenus = try modelContext.fetch(descriptor)
            print("🗑️ Deleting \(existingMenus.count) old menus for current week")
            
            for menu in existingMenus {
                modelContext.delete(menu)
            }
            
            try modelContext.save()
            weeklyMenu = [] // Clear in-memory cache
            print("✅ Old menus deleted successfully")
        } catch {
            print("❌ Failed to delete old menus: \(error)")
        }
    }
    
    private func loadSavedMenus() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get Monday of this week
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = weekday == 1 ? -6 : -(weekday - 2)
        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today) else {
            return
        }
        
        // Precompute end of week (next Monday) outside of the predicate since complex date ops aren't supported in #Predicate
        guard let endOfWeek = calendar.date(byAdding: .day, value: 7, to: monday) else {
            return
        }
        
        // Fetch menus for this week
        let descriptor = FetchDescriptor<DailyMenu>(
            predicate: #Predicate<DailyMenu> { menu in
                menu.date >= monday && menu.date < endOfWeek
            },
            sortBy: [SortDescriptor(\.date)]
        )
        
        do {
            weeklyMenu = try modelContext.fetch(descriptor)
            print("📥 Loaded \(weeklyMenu.count) saved menus from database")
        } catch {
            print("❌ Failed to load menus: \(error)")
            weeklyMenu = []
        }
    }
    
    func generateWeeklyMenu(
            userCycle: UserCycle,
            userLevel: WorkoutLevel,
            chosenDays: [WorkoutDayPreference]
    ) async {
        isLoading = true
        
//        if !weeklyMenu.isEmpty {
//            print("✅ Already have \(weeklyMenu.count) menus loaded in memory")
//            return
//        }
//        
//        let existingMenus = fetchMenusForCurrentWeek()
//        
//        if !existingMenus.isEmpty {
//            print("✅ Using existing weekly menu (\(existingMenus.count) days)")
//            weeklyMenu = existingMenus
//            isLoading = false
//            return
//        }
        
        print("🎯 === GENERATING NEW WEEKLY MENU ===")
        
        // Step 2: Generate new menus (business logic)
        let newMenus = generator.generateWeeklyMenu(
            level: userLevel,
            chosenDays: chosenDays,
            userCycle: userCycle,
            strengthType: .bodyWeight,
            startDate: nil
        )
        
        for menu in newMenus {
            modelContext.insert(menu)
        }
        
        // Step 4: Save to database
        do {
            try modelContext.save()
            print("✅ Saved \(newMenus.count) menus to database")
            
            for menu in newMenus {
                print("   💾 Saved: \(menu.date) - \(menu.dayName)")
            }
        } catch {
            print("❌ Failed to save menus: \(error)")
        }
        
        weeklyMenu = newMenus
//        loadSavedMenus()
        isLoading = false
    }
        
        // MARK: - Fetch Menus for Current Week
    private func fetchMenusForCurrentWeek() -> [DailyMenu] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = weekday == 1 ? -6 : -(weekday - 2)
        
//        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today),
//              let sunday = calendar.date(byAdding: .day, value: 6, to: monday) else {
//            return []
//        }
        
        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today),
              let nextMonday = calendar.date(byAdding: .day, value: 7, to: monday) else {
            return []
        }
        
        print("🔍 Fetching menus for current week:")
        print("   Today: \(today)")
        print("   Monday: \(monday)")
        print("   Next Monday: \(nextMonday)")
        
        
        let allMenusDescriptor = FetchDescriptor<DailyMenu>(
            sortBy: [SortDescriptor(\.date)]
        )
        
        do {
            let allMenus = try modelContext.fetch(allMenusDescriptor)
            print("📊 Total menus in database: \(allMenus.count)")
            for menu in allMenus {
                print("   - \(menu.date): \(menu.dayName)")
            }
        } catch {
            print("❌ Failed to fetch all menus: \(error)")
        }
        
        // Now fetch for this week
        let descriptor = FetchDescriptor<DailyMenu>(
            predicate: #Predicate { menu in
                menu.date >= monday && menu.date < nextMonday
            },
            sortBy: [SortDescriptor(\.date)]
        )
        
        do {
            let menus = try modelContext.fetch(descriptor)
            print("🔍 Found \(menus.count) existing menus in database for this week")
            for menu in menus {
                print("   ✅ \(menu.date): \(menu.dayName)")
            }
            return menus
        } catch {
            print("❌ Failed to fetch menus: \(error)")
            return []
        }
//        let descriptor = FetchDescriptor<DailyMenu>(
//            predicate: #Predicate<DailyMenu> { menu in
//                menu.date >= monday && menu.date <= sunday
//            },
//            sortBy: [SortDescriptor(\.date)]
//        )
//        
//        do {
//            let menus = try modelContext.fetch(descriptor)
//            print("🔍 Found \(menus.count) existing menus in database")
//            for menu in menus {
//                print("   - \(menu.date): \(menu.dayName)")
//            }
//            return menus
//        } catch {
//            print("❌ Failed to fetch menus: \(error)")
//            return []
//        }
    }
    
    // MARK: - Get Menu for Specific Day
//    func getMenu(for dayNumber: Int) -> DailyMenu? {
//        return weeklyMenu.first { $0.dayNumber == dayNumber }
//    }
    
    // MARK: - Get Menu for Date
    func getMenuForDate(_ date: Date) -> DailyMenu? {
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: date)
        
        // Try in-memory first
        if let menu = weeklyMenu.first(where: {
            calendar.isDate($0.date, inSameDayAs: startOfDate)
        }) {
            return menu
        }
        
        // Fallback to database using supported predicate operations
        let endOfDate = calendar.date(byAdding: .day, value: 1, to: startOfDate)!
        let descriptor = FetchDescriptor<DailyMenu>(
            predicate: #Predicate<DailyMenu> { menu in
                menu.date >= startOfDate && menu.date < endOfDate
            }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            return results.first
        } catch {
            print("❌ Failed to fetch menu for date: \(error)")
            return nil
        }
    }
        
        // MARK: - Helper
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }
}

//
//  WorkoutMenuGenerator.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 03/11/25.
//

import Foundation
import SwiftData

class WorkoutMenuGenerator {
    
    private let context: ModelContext
    private var exerciseRepo: ExerciseRepository
    private let generator = WorkoutSplitGenerator()
    
    init(context: ModelContext) {
        self.context = context
        self.exerciseRepo = ExerciseRepository(context: context)
    }
    
    func generateWeeklyMenu(
        level: WorkoutLevel,
        chosenDays: [WorkoutDayPreference],
        userCycle: UserCycle,
        strengthType: StrengthType,
        startDate: Date? = nil
    ) -> [DailyMenu] {
        
        print("\n🎯 === GENERATING WEEKLY MENU ===")
        
        let schedule = generator.generateWeeklySplit(
            chosenDays: chosenDays,
            level: level,
            userCycle: userCycle,
        )
        
        let currentPhase = CyclePhaseCalculator.calculateCurrentPhase(
            lastPeriodStart: userCycle.cycleStartDate,
            menstrualDuration: userCycle.menstrualDuration
        )
        
        print("Current Phase: \(currentPhase.rawValue)")
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let baseDate: Date
        
        if let startDate = startDate {
                baseDate = calendar.startOfDay(for: startDate)
        } else {
            let today = calendar.startOfDay(for: Date())
            let weekday = calendar.component(.weekday, from: today)
            let daysToMonday = weekday == 1 ? -6 : -(weekday - 2)
            baseDate = calendar.date(byAdding: .day, value: daysToMonday, to: today) ?? today
        }
            
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.timeZone = TimeZone.current
        print("📅 Base date (Monday): \(formatter.string(from: baseDate))")
        
        var weeklyMenus: [DailyMenu] = []
        var strengthDayCounter: Int = 0
        var cardioDayCounter: Int = 0
        
        for day in 1...7 {
            let dayName = generator.getDayName(day)
            let category = schedule[day] ?? .rest
            
            guard let menuDate = calendar.date(byAdding: .day, value: day - 1, to: baseDate) else {
                continue
            }
            
            let normalizedDate = calendar.startOfDay(for: menuDate)
            
            let menu: DailyMenu
            
            if category == .strength {
                menu = generateDailyMenu(
                    dayNumber: day,
                    dayName: dayName,
                    date: normalizedDate,
                    category: category,
                    level: level,
                    phase: currentPhase,
                    strengthType: strengthType,
                    strengthDayIndex: strengthDayCounter,
                    cardioDayIndex: 0
                )
                strengthDayCounter += 1
            } else if category == .cardio {
                menu = generateDailyMenu(
                    dayNumber: day,
                    dayName: dayName,
                    date: normalizedDate,
                    category: category,
                    level: level,
                    phase: currentPhase,
                    strengthType: strengthType,
                    strengthDayIndex: 0,
                    cardioDayIndex: cardioDayCounter
                )
                cardioDayCounter += 1
            } else {
                menu = generateDailyMenu(
                    dayNumber: day,
                    dayName: dayName,
                    date: normalizedDate,
                    category: category,
                    level: level,
                    phase: currentPhase,
                    strengthType: strengthType,
                    strengthDayIndex: 0,
                    cardioDayIndex: 0
                )
            }
            
            
            weeklyMenus.append(menu)
            print("📆 Generated menu for \(dayName) (\(formatDate(normalizedDate)))")
        }
        
        print("✅ Generated \(weeklyMenus.count) days\n")
        return weeklyMenus
    }
    
    // MARK: - Generate Single Day Menu
    private func generateDailyMenu(
        dayNumber: Int,
        dayName: String,
        date: Date,
        category: MenuCategory,
        level: WorkoutLevel,
        phase: MenstrualPhase,
        strengthType: StrengthType,
        strengthDayIndex: Int,
        cardioDayIndex: Int
    ) -> DailyMenu {
        
        switch category {
        case .cardio:
            return generateCardioMenu(
                dayNumber: dayNumber,
                dayName: dayName,
                date: date,
                level: level,
                phase: phase,
                cardioDayIndex: cardioDayIndex
            )
            
        case .strength: //generate both bodyweight and gym, not based on level
            return generateStrengthMenu(
                dayNumber: dayNumber,
                dayName: dayName,
                date: date,
                level: level,
                phase: phase,
                strengthType: strengthType,
                strengthDayIndex: strengthDayIndex
        )
            
        case .rest:
            return .restDay(
                dayNumber: dayNumber,
                dayName: dayName,
                date: date
            )
        }
    }

    func generateCardioMenu(
        dayNumber: Int,
        dayName: String,
        date: Date,
        level: WorkoutLevel,
        phase: MenstrualPhase,
        cardioDayIndex: Int
    ) -> DailyMenu {
        
        let cardioDetails = getCardioSpecs(for: level, phase: phase)
        
        return .cardioDay(
            dayNumber: dayNumber,
            dayName: dayName,
            date: date,
            intensity: cardioDetails.intensityLabel,
            estimatedDuration: cardioDetails.vigorousDuration
        )
    }
    
    func generateStrengthMenu(
            dayNumber: Int,
            dayName: String,
            date: Date,
            level: WorkoutLevel,
            phase: MenstrualPhase,
            strengthType: StrengthType,
            strengthDayIndex: Int
        ) -> DailyMenu {
            
            print("\n💪 Generating strength workout for \(dayName)...")
            
            // Step 1: Determine body part focus (rotate throughout week)
//            let bodyPartFocus = determineBodyPartFocus(
//                level: level,
//                strengthDayIndex: strengthDayIndex
//            )
            
            // Step 3: Calculate exercise count
            let exerciseCount = getExerciseCount(for: level, phase: phase)
            print("  Count: \(exerciseCount)")
            
            // Step 4: Fetch exercises from database
            var exercises = exerciseRepo.getExercises(
                forLevel: level,
                phase: phase,
                count: exerciseCount
            )
            
            // Step 5: Adjust sets/reps based on phase
            exercises = adjustExercisesForPhase(exercises, level: level, phase: phase)
            
            // Step 7: Get intensity
            let duration = calculateWorkoutDuration(exercises: exercises)
            let intensity = getIntensity(for: phase)
            
            return .strengthDay(
                dayNumber: dayNumber,
                dayName: dayName,
                date: date,
                strengthType: strengthType,
                strengthExercises: exercises,
                intensity: intensity,
                estimatedDuration: duration
            )
        }
}

extension WorkoutMenuGenerator {
    
    private func determineBodyPartFocus(level: WorkoutLevel, strengthDayIndex: Int) -> BodyPart? {
        switch level {
            case .advanced :
            return strengthDayIndex % 2 == 0 ? .pull : .push
            default : return .pull
        }
    }
       
    private func getExerciseCount(for level: WorkoutLevel, phase: MenstrualPhase) -> Int {
        switch level {
        case .beginner: return 5
        case .intermediate: return 5
        case .advanced: return 5
        }
    }
    
    func getCardioSpecs(for level: WorkoutLevel, phase: MenstrualPhase) -> CardioDetails {
        switch (level, phase) {
            // BEGINNER
        case (.beginner, .menstruation):
            return CardioDetails(
                vigorousDuration: 50,
                moderateDuration: 100,
                targetHeartRate: "70-80% max HR",
                intensityLabel: "Low"
            )
        case (.beginner, .follicular), (.beginner, .ovulation):
            return CardioDetails(
                vigorousDuration: 75,
                moderateDuration: 150,
                targetHeartRate: "70-80% max HR",
                intensityLabel: "High"
            )
        case (.beginner, .luteal):
            return CardioDetails(
                vigorousDuration: 90,
                moderateDuration: 180,
                targetHeartRate: "70-80% max HR",
                intensityLabel: "Moderate"
            )
            
            // INTERMEDIATE
        case (.intermediate, .menstruation):
            return CardioDetails(
                vigorousDuration: 50,
                moderateDuration: 100,
                targetHeartRate: "70-80% max HR",
                intensityLabel: "Low"
            )
        case (.intermediate, .follicular), (.intermediate, .ovulation):
            return CardioDetails(
                vigorousDuration: 75,
                moderateDuration: 150,
                targetHeartRate: "70-80% max HR",
                intensityLabel: "High"
            )
        case (.intermediate, .luteal):
            return CardioDetails(
                vigorousDuration: 90,
                moderateDuration: 180,
                targetHeartRate: "70-80% max HR",
                intensityLabel: "Moderate"
            )
            
            // ADVANCED
        case (.advanced, .menstruation):
            return CardioDetails(
                vigorousDuration: 80,
                moderateDuration: 160,
                targetHeartRate: "70-80% max HR",
                intensityLabel: "Low"
            )
        case (.advanced, .follicular), (.advanced, .ovulation):
            return CardioDetails(
                vigorousDuration: 115,
                moderateDuration: 230,
                targetHeartRate: "70-80% max HR",
                intensityLabel: "High"
            )
        case (.advanced, .luteal):
            return CardioDetails(
                vigorousDuration: 135,
                moderateDuration: 270,
                targetHeartRate: "70-80% max HR",
                intensityLabel: "Moderate"
            )
        }
    }
    
    func getStrengthSpecs(for level: WorkoutLevel, phase: MenstrualPhase) -> StrengthSpecs {
        switch (level, phase) {
        // BEGINNER
        case (.beginner, .menstruation):
            return StrengthSpecs(sets: 2, reps: 8) // 1-2 sets, using 2
        case (.beginner, .follicular), (.beginner, .ovulation):
            return StrengthSpecs(sets: 4, reps: 10)
        case (.beginner, .luteal):
            return StrengthSpecs(sets: 3, reps: 10)
            
        // INTERMEDIATE
        case (.intermediate, .menstruation):
            return StrengthSpecs(sets: 3, reps: 10) // 2-3 sets, using 3
        case (.intermediate, .follicular), (.intermediate, .ovulation):
            return StrengthSpecs(sets: 4, reps: 12) // 3-4 sets, using 4
        case (.intermediate, .luteal):
            return StrengthSpecs(sets: 3, reps: 12)
            
        // ADVANCED
        case (.advanced, .menstruation):
            return StrengthSpecs(sets: 3, reps: 10)
        case (.advanced, .follicular), (.advanced, .ovulation):
            return StrengthSpecs(sets: 6, reps: 12) // 5-6 sets, using 6
        case (.advanced, .luteal):
            return StrengthSpecs(sets: 5, reps: 12) // 4-5 sets, using 5
        }
    }
       
    private func adjustExercisesForPhase(_ exercises: [Exercise], level: WorkoutLevel, phase: MenstrualPhase) -> [Exercise] {
        
        let specs = getStrengthSpecs(for: level, phase: phase)
        
        print("  Applying: \(specs.sets) sets × \(specs.reps) reps")
        
        return exercises.map { exercise in
            var adjusted = exercise
            adjusted.sets = specs.sets
            adjusted.reps = specs.reps
            return adjusted
        }
    }
       
    private func getIntensity(for phase: MenstrualPhase) -> String {
        switch phase {
        case .menstruation: return "Low"
        case .follicular, .ovulation: return "High"
        case .luteal: return "Moderate"
        }
    }
       
       // MARK: - Calculate Workout Duration
       private func calculateWorkoutDuration(exercises: [Exercise]) -> Int {
           var total = 5 // warmup
           
           for exercise in exercises {
               // Each set takes ~3 minutes (exercise + rest)
               total += exercise.sets ?? 0 * 3
           }
           
           total += 5 // cooldown
           return total
       }
       
       // MARK: - Get Cycle Day for Date
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
           
           // Handle negative (shouldn't happen)
           if daysSinceStart < 0 {
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
           
           // Current weekday (1=Monday, 7=Sunday)
           let currentWeekday = calendar.component(.weekday, from: today)
           let currentDayNumber = currentWeekday == 1 ? 7 : currentWeekday - 1
           
           // Calculate difference
           let daysDifference = dayNumber - currentDayNumber
           
           return calendar.date(byAdding: .day, value: daysDifference, to: today) ?? today
       }
       
       // MARK: - Helper: Get Day Name
       private func getDayName(_ day: Int) -> String {
           let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
           return days[day - 1]
       }
       
       // MARK: - Helper: Format Date
       private func formatDate(_ date: Date) -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = "MMM dd"
           return formatter.string(from: date)
       }
}

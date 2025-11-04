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
        strengthType: StrengthType
    ) -> [DailyMenu] {
        
        print("\n🎯 === GENERATING WEEKLY MENU ===")
        
        let schedule = generator.generateWeeklySplit(
            chosenDays: chosenDays,
            level: level,
            userCycle: userCycle,
            //hasCramps: userCycle.hasCrampsToday
        )
        
        let currentPhase = CyclePhaseCalculator.calculateCurrentPhase(
            lastPeriodStart: userCycle.cycleStartDate,
            menstrualDuration: userCycle.cycleLength
        )
        
        print("Current Phase: \(currentPhase.rawValue)")
        
        var weeklyMenus: [DailyMenu] = []
        
        for day in 1...7 {
            let dayName = generator.getDayName(day)
            let category = schedule[day] ?? .rest
            
            let menu = generateDailyMenu(
                dayNumber: day,
                dayName: dayName,
                category: category,
                level: level,
                phase: currentPhase,
                strengthType: strengthType
            )
            
            weeklyMenus.append(menu)
        }
        
        print("✅ Generated \(weeklyMenus.count) days\n")
        return weeklyMenus
    }
    
    // MARK: - Generate Single Day Menu
    private func generateDailyMenu(
        dayNumber: Int,
        dayName: String,
        category: MenuCategory,
        level: WorkoutLevel,
        phase: MenstrualPhase,
        strengthType: StrengthType
    ) -> DailyMenu {
        
        switch category {
        case .cardio:
            return generateCardioMenu(
                dayNumber: dayNumber,
                dayName: dayName,
                phase: phase
            )
            
        case .strength:
            return generateStrengthMenu(
                dayNumber: dayNumber,
                dayName: dayName,
                level: level,
                phase: phase,
                strengthType: strengthType,
            )
            
        case .rest:
            return .restDay(dayNumber: dayNumber, dayName: dayName)
        }
    }
    
    // MARK: - Generate Cardio Menu
    private func generateCardioMenu(
        dayNumber: Int,
        dayName: String,
        phase: MenstrualPhase
    ) -> DailyMenu {
        
        // Adjust intensity based on phase
        //let (intensity, duration) = getCardioIntensity(for: phase)
        
        return .cardioDay(
            dayNumber: dayNumber,
            dayName: dayName
//            intensity: intensity,
//            duration: duration
        )
    }
    
    private func generateStrengthMenu(
            dayNumber: Int,
            dayName: String,
            level: WorkoutLevel,
            phase: MenstrualPhase,
            strengthType: StrengthType
        ) -> DailyMenu {
            
            print("\n💪 Generating strength workout for \(dayName)...")
            
            // Step 1: Determine body part focus (rotate throughout week)
            let bodyPartFocus = determineBodyPartFocus(dayNumber: dayNumber)
            //print("  Body Part: \(bodyPartFocus?.displayName ?? "Any")")
            
            // Step 2: Get exercise types for Keep Fit goal
            let exerciseTypes = getExerciseTypesForKeepFit(phase: phase)
            print("  Types: \(exerciseTypes.map { $0.rawValue }.joined(separator: ", "))")
            
            // Step 3: Calculate exercise count
            let exerciseCount = getExerciseCount(for: level, phase: phase)
            print("  Count: \(exerciseCount)")
            
            // Step 4: Fetch exercises from database
            var exercises = exerciseRepo.getExercises(
                forLevel: level,
                phase: phase,
                bodyPart: bodyPartFocus,
                exerciseTypes: exerciseTypes,
                count: exerciseCount
            )
            
            // Step 5: Adjust sets/reps based on phase
            exercises = adjustExercisesForPhase(exercises, phase: phase)
            
            // Step 6: Calculate duration
            let duration = calculateWorkoutDuration(exercises: exercises)
            
            // Step 7: Get intensity
            let intensity = getIntensity(for: phase)
            
            return .strengthDay(
                dayNumber: dayNumber,
                dayName: dayName,
                strengthType: strengthType
//                exercises: exercises,
//                intensity: intensity,
//                duration: duration
            )
        }
}

extension WorkoutMenuGenerator {
    private func determineBodyPartFocus(dayNumber: Int) -> BodyPart? {
           // For Keep Fit: rotate through body parts
           // Mon = Upper, Wed = Lower, Fri = Core, Sat = Upper, etc.
           let cycle = dayNumber % 3
           switch cycle {
           case 1: return .upper
           case 2: return .lower
           case 0: return .core
           default: return nil
           }
       }
       
       // MARK: - Get Exercise Types for Keep Fit
       private func getExerciseTypesForKeepFit(phase: MenstrualPhase) -> [ExerciseType] {
           // During menstruation: only gentle
           if phase == .menstruation {
               return [.mobility, .stability, .stretch, .lightStrength]
           }
           
           // Keep Fit: balanced mix of strength and stability
           return [.strength, .stability, .compound, .control]
       }
       
       // MARK: - Get Exercise Count
       private func getExerciseCount(for level: WorkoutLevel, phase: MenstrualPhase) -> Int {
           // Reduce during menstruation
           if phase == .menstruation {
               return 3
           }
           
           switch level {
           case .beginner: return 4
           case .intermediate: return 5
           case .advanced: return 6
           }
       }
       
       // MARK: - Adjust Exercises for Phase
       private func adjustExercisesForPhase(_ exercises: [Exercise], phase: MenstrualPhase) -> [Exercise] {
           return exercises.map { exercise in
               var adjusted = exercise
               
               switch phase {
               case .menstruation:
                   // Reduce volume by 30-40%
                   adjusted.sets = max(2, exercise.sets ?? 0 - 1)
                   if let reps = exercise.reps {
                       adjusted.reps = max(5, Int(Double(reps) * 0.7))
                   }
                   
               case .follicular, .ovulation:
                   // Peak performance - increase slightly
                   adjusted.sets = min(5, exercise.sets ?? 0 + 1)
                   
               case .luteal:
                   // Maintain as-is
                   break
               }
               
               return adjusted
           }
       }
       
       // MARK: - Get Intensity for Phase
       private func getIntensity(for phase: MenstrualPhase) -> String {
           switch phase {
           case .menstruation: return "Low"
           case .follicular: return "High"
           case .ovulation: return "Peak"
           case .luteal: return "Moderate"
           }
       }
       
       // MARK: - Get Cardio Intensity
       private func getCardioIntensity(for phase: MenstrualPhase) -> (String, Int) {
           switch phase {
           case .menstruation: return ("Low", 20)
           case .follicular: return ("High", 40)
           case .ovulation: return ("High", 45)
           case .luteal: return ("Moderate", 30)
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

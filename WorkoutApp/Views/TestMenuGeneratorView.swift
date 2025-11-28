//
//  TestMenuGeneratorView.swift
//  WorkoutApp
//

import Foundation
import SwiftData
import SwiftUI

struct TestMenuGeneratorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allExercises: [Exercise]
    
    @State private var weeklyMenu: [DailyMenu] = []
    @State private var isGenerating = false
    
    // Test cycle data - FIXED to match your UserCycle
    @State private var testCycle = UserCycle(
        isCycleRegular: true,
        cycleStartDate: Date().addingTimeInterval(-15 * 24 * 60 * 60), // 3 days ago
        cycleEndDate: Date(),
        cycleLength: 28, // IMPORTANT: This should be your full cycle (not period duration)
        menstrualDuration: 5,
        cycleSymptoms: [.cramps], // User has cramps
        cycleEnergy: .stable,
        cycleMoodAffectsMotivation: .never
    )
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Database Status
                    VStack(spacing: 8) {
                        Text("Database Status")
                            .font(.headline)
                        Text("Total Exercises: \(allExercises.count)")
                            .foregroundStyle(allExercises.isEmpty ? .red : .green)
                        
                        if allExercises.isEmpty {
                            Button("Load Dummy Data") {
                                loadDummyData()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Cycle Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cycle Info:")
                            .font(.headline)
                        Text("Period started: \(formatDate(testCycle.cycleStartDate))")
                        Text("Cycle length: \(testCycle.cycleLength) days")
                        Text("Current cycle day: \(getCurrentCycleDay())")
                        Text("Has cramps: \(testCycle.cycleSymptoms.contains(.cramps) ? "Yes" : "No")")
                            .foregroundStyle(testCycle.cycleSymptoms.contains(.cramps) ? .red : .green)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.pink.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Test Parameters
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Test Parameters:")
                            .font(.headline)
                        Text("• Goal: Keep Fit (Balanced)")
                        Text("• Level: Intermediate")
                        Text("• Days: Mon, Wed, Fri, Sat")
                        Text("• Equipment: Bodyweight")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Generate Button
                    Button {
                        generateMenu()
                    } label: {
                        if isGenerating {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Generate Weekly Menu")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isGenerating || allExercises.isEmpty)
                    
                    if allExercises.isEmpty {
                        Text("⚠️ Load dummy data first")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                    
                    // Display Menus
                    if !weeklyMenu.isEmpty {
                        Divider()
                            .padding(.vertical)
                        
                        Text("Your Weekly Plan")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(weeklyMenu, id: \.id) { menu in
                            DailyMenuCard(menu: menu)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Test Generator")
        }
    }
    
    func loadDummyData() {
        DummyExerciseProvider.shared.insertDummyData(into: modelContext)
    }
    
    func generateMenu() {
        isGenerating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let generator = WorkoutMenuGenerator(context: modelContext)
            
            weeklyMenu = generator.generateWeeklyMenu(
                level: .intermediate,
                chosenDays: [.monday, .wednesday, .friday, .saturday],
                userCycle: testCycle,
                strengthType: .bodyWeight
            )
            
            isGenerating = false
        }
    }
    
    func getCurrentCycleDay() -> Int {
        let calendar = Calendar.current
        let daysSince = calendar.dateComponents(
            [.day],
            from: testCycle.cycleStartDate,
            to: Date()
        ).day ?? 0
        return (daysSince % testCycle.cycleLength) + 1
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Daily Menu Card (FIXED)
struct DailyMenuCard: View {
    let menu: DailyMenu
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(menu.dayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
//                    Text(menu.displayTitle)
//                        .font(.headline)
                }
                
                Spacer()
                
//                Image(systemName: menu.category.icon)
//                    .font(.title2)
//                    .foregroundStyle(categoryColor)
            }
            
            if menu.isStrength {
                if let exercises = menu.strengthExercises {
                    Text("DEBUG: Found \(exercises.count) exercises")
                        .font(.caption2)
                        .foregroundColor(.green)
                } else {
                    Text("DEBUG: strengthExercises is NIL!")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
            
            // Content
            if menu.isStrength, let exercises = menu.strengthExercises {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(exercises, id: \.id) { exercise in
                        HStack {
                            Text("• \(exercise.name)")
                                .font(.subheadline)
                            Spacer()
                            Text(exercise.displayDetails)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            } else if menu.isCardio {
                Text("Choose your cardio activity")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if menu.isRest {
                Text("Rest and recovery day")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
        }
        .padding()
        .background(categoryColor.opacity(0.1))
        .cornerRadius(12)
    }
    
    var categoryColor: Color {
        switch menu.category {
        case .strengthGeneric, .strengthLower, .strengthUpper: return .blue
        case .cardio: return .red
        case .rest: return .green
        }
    }
}

// MARK: - Simple Preview
#Preview {
    TestMenuGeneratorView()
        .modelContainer(for: [Exercise.self], inMemory: true)
}

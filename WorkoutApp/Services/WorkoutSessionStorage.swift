//
//  WorkoutSessionStorage.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 24/11/25.
//

import Foundation
import SwiftData

protocol WorkoutSessionStorageProtocol {
    func saveWorkoutSession(_ session: WorkoutSessionSummary)
    func getAllSessions() -> [WorkoutSessionSummary]
    func getSessions(for date: Date) -> [WorkoutSessionSummary]
    func deleteSession(withId id: UUID)
    func clearOldSessions(olderThan days: Int)
    func clearAllSessions()
}

@MainActor
class WorkoutSessionStorage: WorkoutSessionStorageProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Save
    
    func saveWorkoutSession(_ session: WorkoutSessionSummary) {
        modelContext.insert(session)
        
        do {
            try modelContext.save()
            print("✅ Saved workout session to SwiftData:")
            print("   • Date: \(session.workoutDate)")
            print("   • Duration: \(session.duration)s")
            print("   • Active: \(session.activeEnergy) kcal")
            print("   • Total: \(session.totalEnergy) kcal")
        } catch {
            print("❌ Failed to save workout session: \(error)")
        }
    }
    
    // MARK: - Retrieve
    
    func getAllSessions() -> [WorkoutSessionSummary] {
        let descriptor = FetchDescriptor<WorkoutSessionSummary>(
            sortBy: [SortDescriptor(\.workoutDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ Failed to fetch sessions: \(error)")
            return []
        }
    }
    
    func getSessions(for date: Date) -> [WorkoutSessionSummary] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        
        let predicate = #Predicate<WorkoutSessionSummary> { session in
            session.workoutDate >= startOfDay && session.workoutDate < endOfDay
        }
        
        let descriptor = FetchDescriptor<WorkoutSessionSummary>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.workoutDate)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ Failed to fetch sessions for date: \(error)")
            return []
        }
    }
    
    // MARK: - Delete
    
    func deleteSession(withId id: UUID) {
        let predicate = #Predicate<WorkoutSessionSummary> { $0.id == id }
        let descriptor = FetchDescriptor<WorkoutSessionSummary>(predicate: predicate)
        
        do {
            let sessions = try modelContext.fetch(descriptor)
            for session in sessions {
                modelContext.delete(session)
            }
            try modelContext.save()
            print("🗑️ Deleted workout session: \(id)")
        } catch {
            print("❌ Failed to delete session: \(error)")
        }
    }
    
    func clearOldSessions(olderThan days: Int = 7) {
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) else {
            return
        }
        
        let predicate = #Predicate<WorkoutSessionSummary> { session in
            session.workoutDate < cutoffDate
        }
        
        let descriptor = FetchDescriptor<WorkoutSessionSummary>(predicate: predicate)
        
        do {
            let oldSessions = try modelContext.fetch(descriptor)
            for session in oldSessions {
                modelContext.delete(session)
            }
            try modelContext.save()
            print("🧹 Cleared \(oldSessions.count) old sessions (older than \(days) days)")
        } catch {
            print("❌ Failed to clear old sessions: \(error)")
        }
    }
    
    func clearAllSessions() {
        do {
            try modelContext.delete(model: WorkoutSessionSummary.self)
            try modelContext.save()
            print("🗑️ Cleared all workout sessions")
        } catch {
            print("❌ Failed to clear all sessions: \(error)")
        }
    }
}

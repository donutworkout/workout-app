//
//  WorkoutSessionService.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 24/11/25.
//

import Foundation
import SwiftData

@MainActor
class WorkoutSessionService {
    private let storage: WorkoutSessionStorageProtocol
    
    init(storage: WorkoutSessionStorageProtocol) {
        self.storage = storage
    }
    
    // MARK: - Public API
    
    /// Get aggregated workout summary for a specific date
    func getAggregatedSummary(for date: Date) -> DaySummary {
        let sessions = storage.getSessions(for: date)
        
        guard !sessions.isEmpty else {
            return DaySummary()
        }
        
        return aggregateSessions(sessions)
    }
    
    /// Get weekly summaries (Monday to Sunday)
    func getWeeklySummaries(for weekStartDate: Date) -> [Int: DaySummary] {
        let calendar = Calendar.current
        var summaries: [Int: DaySummary] = [:]
        
        for dayIndex in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayIndex, to: weekStartDate) else {
                summaries[dayIndex] = DaySummary()
                continue
            }
            
            summaries[dayIndex] = getAggregatedSummary(for: date)
        }
        
        return summaries
    }
    
    /// Save a new workout session
    func saveWorkout(
        date: Date,
        duration: TimeInterval,
        activeEnergy: Double,
        totalEnergy: Double,
        avgHeartRate: Double,
        distance: Double
    ) {
        let session = WorkoutSessionSummary(
            workoutDate: date,
            duration: duration,
            activeEnergy: activeEnergy,
            totalEnergy: totalEnergy,
            avgHeartRate: avgHeartRate,
            distance: distance
        )
        
        storage.saveWorkoutSession(session)
    }
    
    /// Get total workouts for a date range
    func getTotalWorkouts(from startDate: Date, to endDate: Date) -> Int {
        return storage.getAllSessions().filter {
            $0.workoutDate >= startDate && $0.workoutDate <= endDate
        }.count
    }
    
    /// Get total calories burned in a date range
    func getTotalCalories(from startDate: Date, to endDate: Date) -> Double {
        return storage.getAllSessions()
            .filter { $0.workoutDate >= startDate && $0.workoutDate <= endDate }
            .reduce(0) { $0 + $1.totalEnergy }
    }
    
    // MARK: - Private Helpers
    
    private func aggregateSessions(_ sessions: [WorkoutSessionSummary]) -> DaySummary {
        var summary = DaySummary()
        var totalHeartRates: [Double] = []
        
        for session in sessions {
            summary.totalDuration += session.duration
            summary.activeCalories += session.activeEnergy
            summary.totalCalories += session.totalEnergy
            summary.workoutCount += 1
            
            if session.avgHeartRate > 0 {
                totalHeartRates.append(session.avgHeartRate)
            }
        }
        
        // Calculate average heart rate across all sessions
        if !totalHeartRates.isEmpty {
            summary.avgHeartRate = totalHeartRates.reduce(0, +) / Double(totalHeartRates.count)
        }
        
        return summary
    }
}

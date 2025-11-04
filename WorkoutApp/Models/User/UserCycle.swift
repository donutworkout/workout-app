//
//  UserCycle.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 17/10/25.
//

import Foundation
import SwiftData

enum CycleSymptoms: String, Codable, CaseIterable {
    case cramps
    case backPain
    case fatigue
    case moodSwing
    case none
    
    var displayName: String {
        switch self {
        case .cramps: return "Cramps"
        case .backPain: return "Back Pain"
        case .fatigue: return "Fatigue/Low Energy"
        case .moodSwing: return "Mood Swing"
        case .none: return "None of the above"
        }
    }
}

enum CycleEnergy: String, Codable, CaseIterable {
    case energetic
    case drops
    case stable
    
    var displayName: String {
        switch self {
        case .energetic: return "I feel more energetic after my period"
        case .drops: return "Drops before/during period"
        case .stable: return "Stay stable"
        }
    }
}

enum CycleMoodAffectsMotivation: String, Codable, CaseIterable {
    case often
    case sometimes
    case never
    
    var displayName: String {
        switch self {
        case .often: return "Often"
        case .sometimes: return "Sometime"
        case .never: return "Never"
        }
    }
}

@Model
class UserCycle: Identifiable {
  
  var id: UUID = UUID()
  var isCycleRegular: Bool = true
  var cycleStartDate: Date = Date()
  var cycleEndDate: Date = Date()
  var cycleLength: Int = 0
  var cycleSymptoms: [CycleSymptoms] = []
  var cycleEnergy: CycleEnergy = CycleEnergy.stable
  var cycleMoodAffectsMotivation: CycleMoodAffectsMotivation = CycleMoodAffectsMotivation.never
  var hasCrampsToday: Bool = false
  var createdAt: Date = Date()

  
  @Relationship(deleteRule: .nullify)
  var user: UserProfile?
  
    init(isCycleRegular: Bool, cycleStartDate: Date, cycleEndDate: Date, cycleLength: Int, cycleSymptoms: [CycleSymptoms], cycleEnergy: CycleEnergy, cycleMoodAffectsMotivation: CycleMoodAffectsMotivation, hasCrampsToday: Bool = false, createdAt: Date = .now) {
    self.isCycleRegular = isCycleRegular
    self.cycleStartDate = cycleStartDate
    self.cycleEndDate = cycleEndDate
    self.cycleLength = cycleLength
    self.cycleSymptoms = cycleSymptoms
    self.cycleEnergy = cycleEnergy
    self.cycleMoodAffectsMotivation = cycleMoodAffectsMotivation
    self.hasCrampsToday = hasCrampsToday
    self.createdAt = createdAt
  }
}

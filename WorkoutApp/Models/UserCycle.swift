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
}

enum CycleEnergy: String, Codable, CaseIterable {
  case energetic
  case drops
  case stable
}

enum CycleMoodAffectsMotivation: String, Codable, CaseIterable {
  case often
  case sometimes
  case never
}

@Model
class UserCycle: Identifiable {
  
  var id: UUID = UUID()
  var isCycleRegular: Bool
  var cycleStartDate: Date
  var cycleEndDate: Date
  var cycleLength: Int
  var cycleSymptoms: CycleSymptoms
  var cycleEnergy: CycleEnergy
  var cycleMoodAffectsMotivation: CycleMoodAffectsMotivation
  
  @Relationship(deleteRule: .nullify)
  var user: UserProfile?
  
  init(isCycleRegular: Bool, cycleStartDate: Date, cycleEndDate: Date, cycleLength: Int, cycleSymptoms: CycleSymptoms, cycleEnergy: CycleEnergy, cycleMoodAffectsMotivation: CycleMoodAffectsMotivation) {
    self.isCycleRegular = isCycleRegular
    self.cycleStartDate = cycleStartDate
    self.cycleEndDate = cycleEndDate
    self.cycleLength = cycleLength
    self.cycleSymptoms = cycleSymptoms
    self.cycleEnergy = cycleEnergy
    self.cycleMoodAffectsMotivation = cycleMoodAffectsMotivation
  }
}

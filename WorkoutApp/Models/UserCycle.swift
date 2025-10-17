//
//  UserCycle.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 17/10/25.
//

import Foundation
import SwiftData

enum CycleBehavior: String, Codable, CaseIterable {
  case buildMuscle = "Build Muscle"
  case loseWeight = "Lose Weight"
  case keepFit = "Keep Fit"
}

@Model
class UserCycle: Identifiable {
  
  var id: UUID = UUID()
  var start_date: Date = Date()
  var end_date: Date = Date()
  var cycleLength: Int
  var behavior: CycleBehavior
  
  @Relationship(deleteRule: .nullify)
  var user: UserProfile?
  
  init(start_date: Date, end_date: Date, cycleLength: Int, behavior: CycleBehavior) {
    self.start_date = start_date
    self.end_date = end_date
    self.cycleLength = cycleLength
    self.behavior = behavior
  }
}

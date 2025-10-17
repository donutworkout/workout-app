//
//  UserCycle.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 17/10/25.
//

import Foundation
import SwiftData

@Model
class UserCycle: Identifiable {
  
  var id: UUID = UUID()
  var start_date: Date = Date()
  var end_date: Date = Date()
  var cycle_length: Int
  
  @Relationship(deleteRule: .nullify, inverse: \UserProfile.id)
  var user: UserProfile?
  
  init(start_date: Date, end_date: Date, cycle_length: Int) {
    self.start_date = start_date
    self.end_date = end_date
    self.cycle_length = cycle_length
  }
}

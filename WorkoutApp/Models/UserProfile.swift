//
//  UserProfile.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 14/10/25.
//

import Foundation
import SwiftData

@Model
class UserProfile: Identifiable {
  var id: UUID = UUID()
  var name: String
  var age: Int
  var weight: Double
  var height: Double
   
  @Relationship(deleteRule: .cascade, inverse: \UserWorkout.user)
  var userWorkouts: [UserWorkout] = []
  
  @Relationship(deleteRule: .cascade, inverse: \UserCycle.user)
  var userCycle: [UserCycle] = []
  
  init(name: String, age: Int, weight: Double, height: Double) {
    self.name = name
    self.age = age
    self.weight = weight
    self.height = height
  }
}

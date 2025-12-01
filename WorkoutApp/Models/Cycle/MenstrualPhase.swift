//
//  MenstrualPhase.swift
//  WorkoutApp
//
//  Created by Nadaa Shafa Nadhifa on 29/10/25.
//

enum MenstrualPhase: String, Codable, CaseIterable {
    case menstruation
    case follicular
    case ovulation
    case luteal
    
    var displayName: String {
        switch self {
        case .menstruation: return "Menstruation"
        case .follicular: return "Follicular"
        case .ovulation: return "Ovulation"
        case .luteal: return "Luteal"
        }
    }
}

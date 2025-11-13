//
//  HapticManager.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 13/11/25.
//

import Foundation
import UIKit

/// Semua tipe haptic yang dipakai di app (extendable)
enum HapticType {
    case adjustReps          // saat menambah/mengurangi reps
    case buttonTap           // tombol (Start, Next, Done, dsb)
    case pickerSelection     // saat slide/scroll picker
    case alertAppear         // saat alert/popup muncul
    case restAdded           // saat menambah rest (+10s)
    case restStart           // saat rest view muncul / rest dimulai
    case countdownTick       // tiap hitungan countdown (3,2,1...)
    case countdownEnd        // saat countdown / rest selesai
    case workoutCompleted    // congrats / selesai workout
}

final class HapticManager {
    static let shared = HapticManager()
    private init() {}
    
    /// Trigger haptic berdasarkan tipe yang konsisten
    func trigger(_ type: HapticType) {
        switch type {
        case .buttonTap:
            impact(style: .medium)
            
        case .pickerSelection:
            selection()
            
        case .alertAppear:
            impact(style: .heavy)
            notification(type: .warning)
            
        case .restAdded:
            impact(style: .rigid)
            
        case .restStart:
            impact(style: .medium)
            
        case .countdownTick:
            impact(style: .light)
            
        case .countdownEnd:
            notification(type: .success)
            
        case .workoutCompleted:
            notification(type: .success)
            
        case .adjustReps:
            impact(style: .rigid)
        }
    }
}

// MARK: - Private helpers
private extension HapticManager {
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let g = UIImpactFeedbackGenerator(style: style)
        g.prepare()
        g.impactOccurred()
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(type)
    }
    
    func selection() {
        let g = UISelectionFeedbackGenerator()
        g.prepare()
        g.selectionChanged()
    }
}

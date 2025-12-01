//
//  CardioStartView.swift
//  WorkoutWacthApp Watch App
//
//  Created by Jennifer Evelyn on 03/11/25.
//

import SwiftUI
import HealthKit

struct StartView: View {
    @State private var currentTime = ""
    var workoutType: HKWorkoutActivityType
    @Environment var connectivity: WatchConnectivityManager
    @Environment var sessionManager: WorkoutSessionManager
    
    // Timer for updating time
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var workoutInfo: (name: String, icon: String) {
        let indoor = connectivity.selectedIsIndoor
            switch workoutType {
            case .running: return (
                    indoor ? "Indoor Run" : "Outdoor Run",
                    indoor ? "figure.run.treadmill" : "figure.run")
        case .cycling: return ("Cycling", "figure.outdoor.cycle")
        case .walking: return (
                       indoor ? "Indoor Walk" : "Outdoor Walk",
                       indoor ? "figure.walk.treadmill" : "figure.walk")
        case .swimming: return ("Swimming", "figure.pool.swim")
        case .badminton: return ("Badminton", "figure.badminton")
        case .basketball: return ("Basketball", "figure.basketball")
        case .tennis: return ("Tennis", "figure.tennis")
        case .volleyball: return ("Volleyball", "figure.volleyball")
        case .soccer: return ("Soccer", "figure.soccer")
        case .coreTraining: return ("Core Training", "figure.core.training")
        case .highIntensityIntervalTraining: return ("HIIT", "figure.highintensity.intervaltraining")
        case .traditionalStrengthTraining: return ("Strength", "figure.strengthtraining.traditional")
        case .functionalStrengthTraining: return ("Functional", "figure.strengthtraining.functional")
        default: return ("Workout", "figure.mixed.cardio")
        }
    }
    
    private var categoryName: String {
        let cardio: [HKWorkoutActivityType] = [.running, .cycling, .walking, .swimming, .badminton, .basketball, .tennis, .volleyball, .soccer]
        let strength: [HKWorkoutActivityType] = [.traditionalStrengthTraining, .functionalStrengthTraining, .coreTraining, .highIntensityIntervalTraining]
        let mindBody: [HKWorkoutActivityType] = [.pilates, .yoga, .martialArts]
        
        if cardio.contains(workoutType) { return "Cardio" }
        if strength.contains(workoutType) { return "Strength" }
        if mindBody.contains(workoutType) { return "Mind & Body" }
        return "Workout"
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // MARK: - Time
//            Text(currentTime)
//                .font(.system(size: 16, weight: .regular, design: .rounded))
//                .foregroundColor(.black.opacity(0.8))
//                .padding(.top, 10)
            
            // MARK: - Category
            Text(categoryName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                )
                .padding(.bottom, 16)
            
            // MARK: - Icon + Name
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: workoutInfo.icon)
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundColor(Color("pinkTextPrimary"))
                }
                
                Text(workoutInfo.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 8)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        // MARK: - Anchored Bottom Button with PrimaryGlassButton
        .safeAreaInset(edge: .bottom) {
            PrimaryGlassButton(title: "START", icon: "play.fill") {
                connectivity.sendMessage([
                    "cmd": WorkoutCommand.start.rawValue,
                    "workoutType": workoutType.rawValue,
                    "isIndoor": connectivity.selectedIsIndoor
                ])
                WKInterfaceDevice.current().play(.start)
                print("Starting \(workoutInfo.name) workout")
            }
            .frame(height: 40)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        
        .onReceive(timer) { _ in updateTime() }
        .onAppear { updateTime() }
    }
    
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        currentTime = formatter.string(from: Date())
    }
}

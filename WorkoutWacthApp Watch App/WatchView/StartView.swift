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
        switch workoutType {
        case .running: return ("Running", "figure.run")
        case .cycling: return ("Cycling", "figure.outdoor.cycle")
        case .walking: return ("Walking", "figure.walk")
        case .swimming: return ("Swimming", "figure.pool.swim")
        case .badminton: return ("Badminton", "figure.badminton")
        case .basketball: return ("Basketball", "figure.basketball")
        case .tennis: return ("Tennis", "figure.tennis")
        case .volleyball: return ("Volleyball", "figure.volleyball")
        case .soccer: return ("Soccer", "figure.soccer")
        case .pilates: return ("Pilates", "figure.pilates")
        case .yoga: return ("Yoga", "figure.yoga")
        case .coreTraining: return ("Core Training", "figure.core.training")
        case .highIntensityIntervalTraining: return ("HIIT", "figure.highintensity.intervaltraining")
        case .traditionalStrengthTraining: return ("Strength", "figure.strengthtraining.traditional")
        case .functionalStrengthTraining: return ("Functional", "figure.strengthtraining.functional")
        case .martialArts: return ("Martial Arts", "figure.martial.arts")
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
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(.black.opacity(0.9))
                .padding(.top, -10)
            
            Spacer(minLength: 8)
            
            // MARK: - Icon + Name
            VStack(spacing: 6) {
                Image(systemName: workoutInfo.icon)
                    .font(.system(size: 40))
                    .foregroundColor(Color("pinkTextPrimary"))
                
                Text(workoutInfo.name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        
        // MARK: - Always-Anchored Bottom Button
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                connectivity.sendMessage([
                    "cmd": WorkoutCommand.start.rawValue,
                    "workoutType": workoutType.rawValue
                ])
                print("Starting \(workoutInfo.name) workout")
            }) {
                Text("START")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color("pinkTextPrimary"))
                    )
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 4) 
            .background(Color.black)
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

//#Preview {
//    StartView(workoutType: .running)
//}

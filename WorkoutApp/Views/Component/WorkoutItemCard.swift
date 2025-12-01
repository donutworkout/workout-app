//
//  WorkoutItemCard.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 24/10/25.
//

import SwiftUI

struct WorkoutItemCard: View {
    let workout: Exercise
    let sets: Int
    @State private var reps: Int
    @State private var time: Int
    
    init(workout: Exercise) {
        self.workout = workout
        self.sets = workout.sets ?? 0
        _reps = State(initialValue: workout.reps ?? 1)
        _time = State(initialValue: workout.time ?? 0)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            if let imageName = workout.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .cornerRadius(16)
            } else {
                
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(workout.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                
                if workout.time != nil {
                    Text("\(sets) x \(time) sec")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                } else {
                    Text("\(sets) x \(reps)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // MARK: - Plus & Minus
            HStack(spacing: 12) {
                if reps <= 8 {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 28, height: 28)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                } else {
                    Button(action: {
                        reps -= 1
                        HapticManager.shared.trigger(.adjustReps)
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 28, height: 28)
                            .background(Color("pinkTextSecondary").opacity(0.15))
                            .clipShape(Circle())
                            .foregroundColor(Color("pinkTextPrimary"))
                    }
                }
                
                Button(action: {
                    if workout.time != nil {
                        time += 10
                        HapticManager.shared.trigger(.adjustReps)
                    } else {
                        reps += 1
                        HapticManager.shared.trigger(.adjustReps)
                    }
                    HapticManager.shared.trigger(.adjustReps)
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 28, height: 28)
                        .background(Color("pinkTextPrimary"))
                        .clipShape(Circle())
                        .foregroundColor(Color(.white))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.15), radius: 3, x: 0, y: 2)
        )
    }
}

//
//  WorkoutItemCard.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 24/10/25.
//

import SwiftUI

struct WorkoutItemCard: View {
    let workout: Exercise
    @State private var sets: Int
    let reps: Int
    @State private var time: Int
    
    init(workout: Exercise) {
        self.workout = workout
        _sets = State(initialValue: workout.sets ?? 1)
        self.reps = workout.reps ?? 0
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
                    Text("\(time) seconds")
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
                Button(action: {
                    if workout.time != nil {
                        if time <= workout.time ?? 0 {
                            HapticManager.shared.trigger(.adjustReps)
                        } else {
                            time -= 10
                            HapticManager.shared.trigger(.adjustReps)
                        }
                    } else {
                        if sets <= workout.sets ?? 0 {
                            HapticManager.shared.trigger(.adjustReps)
                        } else {
                            sets -= 1
                            HapticManager.shared.trigger(.adjustReps)
                        }
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 28, height: 28)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    if workout.time != nil {
                        time += 10
                        HapticManager.shared.trigger(.adjustReps)
                    } else {
                        sets += 1
                        HapticManager.shared.trigger(.adjustReps)
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 28, height: 28)
                        .background(Color("pinkTextPrimary").opacity(0.15))
                        .clipShape(Circle())
                        .foregroundColor(Color("pinkTextPrimary"))
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

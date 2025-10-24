//
//  WorkoutItemCard.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 24/10/25.
//

import SwiftUI

struct WorkoutItemCard: View {
    let workout: WorkoutItem
    @State private var count: Int = 0
    
    var body: some View {
        HStack(spacing: 16) {
            Image(workout.image)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(workout.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                Text(workout.detail)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: { if count > 0 { count -= 1 } }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 28, height: 28)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }
                
                Button(action: { count += 1 }) {
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

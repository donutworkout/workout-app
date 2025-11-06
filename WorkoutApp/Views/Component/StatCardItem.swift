//
//  StatCard.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 27/10/25.
//

import SwiftUI

struct StatCardItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("pinkTextPrimary"))
                
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}

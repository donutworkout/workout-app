//
//  StatCard.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 27/10/25.
//

import SwiftUI

// MARK: - Stat Card Reusable
struct StatCard: View {
    var title: String
    var color: Color
    
    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(color)
                    .shadow(color: .gray.opacity(0.15), radius: 4, x: 0, y: 2)
            )
    }
}

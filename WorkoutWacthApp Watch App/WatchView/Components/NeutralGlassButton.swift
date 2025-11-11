//
//  NeutralGlassButton.swift
//  WorkoutWacthApp Watch App
//
//  Created by Jennifer Evelyn on 05/11/25.
//

import SwiftUI

struct NeutralGlassButton: View {
    var title: String
    var icon: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .imageScale(.medium)
                Text(title)
            }
            .font(.system(.headline, design: .rounded))
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(Color.red)
        }
        .glassEffect(.regular.tint(.clear).interactive())
        .clipShape(Capsule())
    }
}

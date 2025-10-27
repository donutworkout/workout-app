//
//  NeutralGlassButton.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 27/10/25.
//

import SwiftUI

struct NeutralGlassButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .foregroundStyle(.black)
        }
        .glassEffect(.regular.tint(.clear).interactive()) // tanpa warna tint
    }
}

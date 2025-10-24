//
//  HeaderButton.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 22/10/25.
//

import SwiftUI

struct HeaderButton: View {
    var title: String
    var isEditing: Bool
    var onClose: () -> Void
    var onEditToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onClose) {
                ZStack {
                    Circle()
                        .fill(Color.secondary)
                        .glassEffect(.regular)
                        .frame(width: 36, height: 36)
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.grayTextPrimary)
                }
            }
            
            Spacer()
            
            // Title
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            // Edit / Save Button (lingkaran saat editing)
            if isEditing {
                Button(action: onEditToggle) {
                    ZStack {
                        Circle()
                            .fill(Color("pinkTextPrimary"))
                            .glassEffect(.regular)
                            .frame(width: 36, height: 36)
                        Image(systemName: "checkmark")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
            } else {
                Button(action: onEditToggle) {
                    Text("Edit")
                        .font(.title3)
                        .foregroundColor(Color("pinkTextPrimary"))
                        .padding(.vertical, 6)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

#Preview("Editing") {
    VStack(spacing: 20) {
        HeaderButton(
            title: "About Me",
            isEditing: false,
            onClose: {},
            onEditToggle: {}
        )
        HeaderButton(
            title: "About Me",
            isEditing: true,
            onClose: {},
            onEditToggle: {}
        )
    }
    .padding()
    .background(Color.white)
}

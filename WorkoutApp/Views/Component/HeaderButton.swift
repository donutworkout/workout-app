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
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // MARK: - Title
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer()
            
            // MARK: - Edit / Save Button
            if isEditing {
                // ✅ Save Button (Checkmark)
                Button(action: onEditToggle) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("pinkTextPrimary"))
                        .frame(width: 40, height: 40)
                        .background(Color("pinkTextPrimary").opacity(0.15))
                        .clipShape(Circle())
                }
            } else {
                // ✅ Edit Button (Text)
                Button(action: onEditToggle) {
                    Text("Edit")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("pinkTextPrimary"))
                        .frame(width: 40, height: 40)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

#Preview("HeaderButton") {
    VStack(spacing: 20) {
        HeaderButton(
            title: "Menstrual Cycle",
            isEditing: false,
            onClose: {},
            onEditToggle: {}
        )
        
        HeaderButton(
            title: "Menstrual Cycle",
            isEditing: true,
            onClose: {},
            onEditToggle: {}
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

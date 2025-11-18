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
                        .fill(Color(.systemGray5))
                        .glassEffect(.regular)
                        .frame(width: 30, height: 30)    // lebih kecil natural iOS
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.gray)
                }
            }
            
            Spacer()
            
            // MARK: - Title (iOS size default)
            Text(title)
                .font(.headline)                     // default iPhone style
                .foregroundColor(.black)
            
            Spacer()
            
            // MARK: - Edit / Save Button
            if isEditing {
                Button(action: onEditToggle) {
                    ZStack {
                        Circle()
                            .fill(Color("pinkTextPrimary"))
                            .glassEffect(.regular)
                            .frame(width: 30, height: 30)  // lebih kecil
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            } else {
                Button(action: onEditToggle) {
                    Text("Edit")
                        .font(.callout)                 // lebih kecil, seperti iOS
                        .foregroundColor(Color("pinkTextPrimary"))
                        .padding(.vertical, 4)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 6)
        .padding(.bottom, 10)
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
    .background(Color.white)
}

//
//  PickerSheetView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 16/10/25.
//

import SwiftUI

struct PickerSheetView: View {
    let title: String
    let unit: String
    let range: [Int]
    @Binding var selection: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - Indicator
            Capsule()
                .fill(Color("pinkTextSecondary").opacity(0.8))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            
            // MARK: - Title
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.top, 10)
            
            // MARK: - Picker
            Picker(title, selection: $selection) {
                ForEach(range, id: \.self) { value in
                    Text("\(value) \(unit)")
                        .font(.system(size: 22, weight: .semibold))
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(height: 180)
            
            // MARK: - Done Button (same style as PrimaryGlassButton)
            PrimaryGlassButton(title: "Done") {
                dismiss()
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .presentationDetents([.height(300)])
        .background(Color.white)
    }
}

#Preview {
    PickerSheetView(
        title: "Select Height",
        unit: "cm",
        range: Array(100...220),
        selection: .constant(165)
    )
}

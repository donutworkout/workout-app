//
//  PickerSheet.swift
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
            Capsule()
                .fill(Color("pinkTextSecondary").opacity(0.8))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            
            Text(title)
                .font(.headline)
                .padding(.top, 10)
            
            Picker(title, selection: $selection) {
                ForEach(range, id: \.self) { value in
                    Text("\(value) \(unit)")
                        .font(.system(size: 22, weight: .semibold))
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(height: 180)
            
            Button("Done") {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("pinkTextSecondary"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .presentationDetents([.height(300)])
        .background(Color.white)
    }
}

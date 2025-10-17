//
//  SurveySection.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 17/10/25.
//

import SwiftUI

// MARK: - Reusable Survey Section
struct SurveySection: View {
    let title: String
    let subtitle: String
    let options: [String]
    @Binding var selectedOptions: [String]
    var allowsMultipleSelection: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("pinkTextSecondary"))
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(Color("pinkTextSecondary"))
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    SelectableButton(
                        title: option,
                        isSelected: selectedOptions.contains(option)
                    ) {
                        if allowsMultipleSelection {
                            // Multi-select logic
                            if selectedOptions.contains(option) {
                                selectedOptions.removeAll { $0 == option }
                            } else {
                                selectedOptions.append(option)
                            }
                        } else {
                            // Single-select logic
                            selectedOptions = [option]
                        }
                    }
                }
            }
            .padding(16)
            .glassEffect(in: .rect(cornerRadius: 25.0))
        }
    }
}

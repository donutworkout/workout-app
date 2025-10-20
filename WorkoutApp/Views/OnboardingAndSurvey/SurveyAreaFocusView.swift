//
//  SurveyAreaFocusView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI

struct SurveyAreaFocusView: View {
    var onNext: () -> Void
    @State private var selectedFocus: [String] = []
    
    let focus = ["Toned Arms", "Flat Abs", "Bubble Butt", "Slim Leg", "Full Body"]
    
    var body: some View {
        VStack(spacing: 32) {
            
            // MARK: - Header
            Text("Survey")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.top, 8)
            
            // MARK: - Title & Character
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Which area\nwould you like to\nfocus on?")
                            .font(.system(.title, weight: .bold))
                            .foregroundColor(Color("pinkTextPrimary"))
                    }
                    Spacer()
                    Image("characterSurvey")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                }
            }
            .padding(.top, 10)
            .padding(.horizontal)
            
            // MARK: - Selectable Buttons
            VStack(spacing: 12) {
                ForEach(focus, id: \.self) { goal in
                    SelectableButton(
                        title: goal,
                        isSelected: selectedFocus.contains(goal)
                    ) {
                        if selectedFocus.contains(goal) {
                            selectedFocus.removeAll { $0 == goal }
                        } else {
                            selectedFocus.append(goal)
                        }
                    }
                }
            }
            .padding(16)
            .glassEffect(in: .rect(cornerRadius: 25.0))
            .padding(.horizontal)
            
            Spacer()
            
            // MARK: - Next Button
            PrimaryGlassButton(title: "Next", action: onNext)
                .padding(.horizontal)
                .padding(.vertical)
                .disabled(selectedFocus.isEmpty) // tidak bisa lanjut kalau belum pilih
                .opacity(selectedFocus.isEmpty ? 0.5 : 1.0)
            
            PageControl(totalPages: 7, currentPage: 3)

        }
    }
}

#Preview {
    SurveyAreaFocusView(onNext: {})
}

//
//  EditBodyInfoView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 30/10/25.
//

import SwiftUI

struct EditBodyInfoView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedHeight: Int = 0
    @State private var selectedWeight: Int = 0
    @State private var showHeightPicker = false
    @State private var showWeightPicker = false
    
    let heights = Array(100...220)
    let weights = Array(30...150)
    
    // MARK: - Validation
    var isFormValid: Bool {
        selectedHeight != 0 && selectedWeight != 0
    }
    
    var body: some View {
        VStack(spacing: 32) {
            
            // MARK: - Header (pakai HeaderButton)
            HeaderButton(
                title: "Body Measurement",
                isEditing: true,
                onClose: { dismiss() },
                onEditToggle: { dismiss() }
            )
            
            // MARK: - Title & Character
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Adjust your body info")
                            .font(.system(.title2, weight: .semibold))
                            .foregroundColor(Color("pinkTextPrimary"))
                    }
                    Spacer()
                    Image("characterSurvey")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // MARK: - Height Field
            HStack {
                Text("Height")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("pinkTextSecondary"))
                Spacer()
                Button {
                    showHeightPicker = true
                } label: {
                    Text(selectedHeight == 0 ? "Select" : "\(selectedHeight) cm")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.grayTextInput)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
            
            // MARK: - Weight Field
            HStack {
                Text("Weight")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("pinkTextSecondary"))
                Spacer()
                Button {
                    showWeightPicker = true
                } label: {
                    Text(selectedWeight == 0 ? "Select" : "\(selectedWeight) kg")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.grayTextInput)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true) // ✅ hilangkan back bawaan
        .sheet(isPresented: $showHeightPicker) {
            PickerSheetView(
                title: "Select Height",
                unit: "cm",
                range: heights,
                selection: $selectedHeight
            )
        }
        .sheet(isPresented: $showWeightPicker) {
            PickerSheetView(
                title: "Select Weight",
                unit: "kg",
                range: weights,
                selection: $selectedWeight
            )
        }
    }
}

#Preview {
    NavigationStack {
        EditBodyInfoView()
    }
}

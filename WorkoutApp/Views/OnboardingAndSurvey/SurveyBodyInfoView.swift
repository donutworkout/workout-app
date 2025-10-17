//
//  SurveyHeightWeightView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 16/10/25.
//

import SwiftUI

struct SurveyBodyInfoView: View {
    @State private var selectedHeight: Int = 0
    @State private var selectedWeight: Int = 0
    
    @State private var showHeightPicker = false
    @State private var showWeightPicker = false
    
    let heights = Array(100...220)
    let weights = Array(30...150)
    
    var onNext: () -> Void
    
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
                        Text("Get to know\nyou more!")
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
            
            // MARK: - Height Field
            HStack() {
                Text("Height")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("pinkTextSecondary"))
                Spacer()
                Button {
                    showHeightPicker = true
                } label: {
                    
                    Text("\(selectedHeight) cm")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                    
                }
            }
            .padding(.horizontal)
            
            // MARK: - Weight Field
            HStack() {
                Text("Weight")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("pinkTextSecondary"))
                Spacer()
                Button {
                    showWeightPicker = true
                } label: {
                    
                    Text("\(selectedWeight) kg")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                    
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // MARK: - Next Button
            Button(action: {
                if selectedHeight != 0 && selectedWeight != 0 {
                    onNext()
                }
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(selectedHeight != 0 && selectedWeight != 0 ?
                                  Color("pinkTextSecondary") :
                                    Color.gray.opacity(0.4))
                    )
                    .animation(.easeInOut(duration: 0.2), value: selectedHeight)
                    .animation(.easeInOut(duration: 0.2), value: selectedWeight)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .disabled(selectedHeight == 0 || selectedWeight == 0)
            
            
            //            // MARK: - Page Indicator
            //            HStack(spacing: 6) {
            //                ForEach(0..<6) { index in
            //                    Circle()
            //                        .fill(index == 1 ? .black : .gray.opacity(0.3))
            //                        .frame(width: 8, height: 8)
            //                }
            //            }
            //            .padding(.bottom, 20)
            
            
            
        }
        .background(Color.white.ignoresSafeArea())
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
    SurveyBodyInfoView(onNext: {})
}

////
////  SurveyWorkoutLevelView.swift
////  WorkoutApp
////
////  Created by Jennifer Evelyn on 15/10/25.
////
//
//import SwiftUI
//
//struct SurveyFitnessLevelView: View {
//    var onNext: () -> Void
//    @State private var selectedLevel: String? = nil
//    
//    let level = ["Beginner (1x / week)", "Intermediate (3x / week)", "Advanced (5–6x / week)"]
//    
//    var body: some View {
//        VStack(spacing: 32) {
//            // MARK: - Header
//            Text("Survey")
//                .font(.headline)
//                .foregroundColor(.black)
//                .padding(.top, 8)
//            
//            // MARK: - Title & Character
//            VStack(spacing: 16) {
//                HStack {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Fitness Level")
//                            .font(.system(.title, weight: .bold))
//                            .foregroundColor(Color("pinkTextPrimary"))
//                    }
//                    Spacer()
//                    Image("characterSurvey")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 120)
//                }
//            }
//            .padding(.top, 10)
//            .padding(.horizontal)
//            
//            // MARK: - Button Options
//            VStack(spacing: 12) {
//                ForEach(level, id: \.self) { goal in
//                    SelectableButton(
//                        title: goal,
//                        isSelected: selectedLevel == goal
//                    ) {
//                        // Pilih hanya satu
//                        if selectedLevel == goal {
//                            selectedLevel = nil // batalkan pilihan
//                        } else {
//                            selectedLevel = goal
//                        }
//                    }
//                }
//            }
//            .padding(16)
//            .glassEffect(in: .rect(cornerRadius: 25.0))
//            .padding(.horizontal)
//            
//            Spacer()
//            
//            // MARK: - Next Button
//            PrimaryGlassButton(title: "Next", action: onNext)
//                .padding(.horizontal)
//                .padding(.vertical)
//                .disabled(selectedLevel == nil) // disable kalau belum pilih
//                .opacity(selectedLevel == nil ? 0.5 : 1)
//            
//            PageControl(totalPages: 7, currentPage: 4)
//
//        }
//    }
//}
//
//#Preview {
//    SurveyFitnessLevelView(onNext: {})
//}

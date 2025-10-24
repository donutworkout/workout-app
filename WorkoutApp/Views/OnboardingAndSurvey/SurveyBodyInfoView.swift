//
//  SurveyHeightWeightView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 16/10/25.
//

import SwiftUI
import SwiftData

struct SurveyBodyInfoView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var surveyManager: SurveyManager
    
    @State private var selectedHeight: Int = 0
    @State private var selectedWeight: Int = 0
    
    @State private var showHeightPicker = false
    @State private var showWeightPicker = false
    
    let heights = Array(100...220)
    let weights = Array(30...150)
    
    var onNext: () -> Void
    
    // MARK: - Validation
    var isFormValid: Bool {
        selectedHeight != 0 && selectedWeight != 0
    }
    
    private func saveAndNext() {
        surveyManager.updateTempHeight(selectedHeight)
        surveyManager.updateTempWeight(selectedWeight)
        
        print("hw saved, button clicked")
        surveyManager.finalizeUserProfile()
        
        checkLocalData()
        onNext()
    }
    
    private func checkLocalData() {
      let descriptor = FetchDescriptor<UserProfile>()
      if let profiles = try? modelContext.fetch(descriptor) {
          print("🔍 Local profiles count: \(profiles.count)")
          for profile in profiles {
              print("   Name: '\(profile.name)', Age: \(profile.age), Weight: \(profile.weight), Height: \(profile.height)")
          }
      } else {
          print("❌ Could not fetch profiles")
      }
    }
    
    var body: some View {
        VStack(spacing: 32) {
            
            // MARK: - Header
            Text("Survey")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.top, 20)
            
            // MARK: - Title & Character
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        SurveyProgressText(currentPage: 2, totalPages: 6)
                        Text("Body Measurement")
                            .font(.system(.title, weight: .semibold))
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
            
            // MARK: - Next Button (Reusable)
            PrimaryGlassButton(title: "Next", action: saveAndNext)
                .padding(.horizontal)
                .padding(.bottom)
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1 : 0.5)
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
//        .onAppear {
//            if surveyManager == nil {
//                surveyManager = SurveyManager(modelContext: modelContext)
//            }
//        }
    }
}


//#Preview {
//    SurveyBodyInfoView(onNext: {})
//}

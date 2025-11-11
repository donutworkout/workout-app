//
//  SurveyBirthdayView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI
import SwiftData

struct SurveyBirthdayView: View {
    @EnvironmentObject var surveyManager: SurveyManager
  
    @State private var selectedYear: Int = 2003
    @State private var name: String = ""
    let years = Array(1980...2025)
  
    var onNext: () -> Void
    
    // MARK: - Validation (cek apakah nama sudah diisi)
    var isNameFilled: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var calculateAge: Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        return currentYear - selectedYear
    }
    
    private func saveAndNext() {
        surveyManager.updateTempName(name.trimmingCharacters(in: .whitespaces))
        surveyManager.updateTempAge(calculateAge)
        print("✅ Saved: \(name), \(calculateAge)")
        onNext()
    }

    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // MARK: - Header & Title
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            SurveyProgressText(currentPage: 1, totalPages: 5)
                            Text("Get to know you more!")
                                .font(.system(.title, weight: .semibold))
                                .foregroundColor(Color("pinkTextPrimary"))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Image("characterSurvey")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // MARK: - Name Input
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Name")
                            .font(.title3)
                            .bold()
                            .foregroundColor(Color("pinkTextSecondary"))
                        
                        TextField("Answer", text: $name)
                            .textInputAutocapitalization(.words)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                            )
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Year Picker
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Year of Birth")
                            .font(.title3)
                            .bold()
                            .foregroundColor(Color("pinkTextSecondary"))
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                            
                            VStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color("pinkTextPrimary").opacity(0.7))
                                    .frame(height: 30)
                                    .frame(width: 350)
                                    .cornerRadius(16)
                                Spacer()
                            }
                            .allowsHitTesting(false)
                            
                            Picker("Year", selection: $selectedYear) {
                                ForEach(years, id: \.self) { year in
                                    Text(String(year))
                                        .font(.title2)
                                        .foregroundColor(.black)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 150)
                            .clipped()
                        }
                        .frame(height: 180)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100) // untuk beri ruang biar scroll tidak nabrak tombol
                }
            }
            
            // MARK: - Next Button (fixed di bawah seperti SurveyBodyInfoView)
            PrimaryGlassButton(title: "Next", action: saveAndNext)
                .padding(.horizontal)
                .padding(.bottom)
                .disabled(!isNameFilled)
                .opacity(isNameFilled ? 1 : 0.5)
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            if !surveyManager.tempName.isEmpty {
                name = surveyManager.tempName
            }
            if surveyManager.tempAge > 0 {
                let currentYear = Calendar.current.component(.year, from: Date())
                selectedYear = currentYear - surveyManager.tempAge
            }
        }
    }
}

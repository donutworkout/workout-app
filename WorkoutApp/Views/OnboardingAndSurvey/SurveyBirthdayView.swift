//
//  SurveyBirthdayView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI

struct SurveyBirthdayView: View {
    @State private var selectedYear: Int = 2003
    @State private var name: String = ""
    let years = Array(1980...2025)
    var onNext: () -> Void
    
    // MARK: - Validation (cek apakah nama sudah diisi)
    var isNameFilled: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
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
                        SurveyProgressText(currentPage: 1, totalPages: 6)
                        
                        Text("Get to know you more!")
                            .font(.system(.title, weight: .semibold))
                            .foregroundColor(Color("pinkTextPrimary"))
                            .lineLimit(nil) // memastikan tidak terpotong
                            .fixedSize(horizontal: false, vertical: true) // biar wrap teks
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
            
            // MARK: - Name
            VStack(alignment: .leading, spacing: 16) {
                Text("Name")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color("pinkTextSecondary"))
                
                TextField("Answer", text: $name)
                    .textInputAutocapitalization(.words)
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
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("pinkTextSecondary").opacity(0.8))
                        .frame(height: 30)
                        .padding(.horizontal, 8)
                    
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(format: "%d", year))
                                .font(.title2)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 250)
                    .compositingGroup()
                    .clipped()
                }
            }
            .padding(.horizontal)
            .glassEffect(in: .rect(cornerRadius: 25.0))
            
            Spacer()
            
            // MARK: - Next Button (disabled kalau nama kosong)
            PrimaryGlassButton(title: "Next", action: onNext)
                .padding(.horizontal)
                .padding(.vertical)
                .disabled(!isNameFilled)
                .opacity(isNameFilled ? 1 : 0.5)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    SurveyBirthdayView(onNext: {})
}

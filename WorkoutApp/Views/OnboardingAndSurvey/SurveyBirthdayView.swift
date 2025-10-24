//
//  SurveyBirthdayView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI
import CloudKit
import SwiftData

struct SurveyBirthdayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var surveyManager: SurveyManager?
  
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
        surveyManager?.updateTempName(name.trimmingCharacters(in: .whitespaces))
        surveyManager?.updateTempAge(calculateAge)
      
        checkLocalData()
        
        onNext()
    }
    
    private func checkLocalData() {
      let descriptor = FetchDescriptor<UserProfile>()
      if let profiles = try? modelContext.fetch(descriptor) {
          print("🔍 Local profiles count: \(profiles.count)")
          for profile in profiles {
              print("   Name: '\(profile.name)', Age: \(profile.age)")
          }
      } else {
          print("❌ Could not fetch profiles")
      }
    }
    
//    
//    func checkCloudKitStatus() {
//      CKContainer.default().accountStatus { status, error in
//          switch status {
//          case .available:
//              print("✅ iCloud available")
//          case .noAccount:
//              print("❌ No iCloud account")
//          case .restricted:
//              print("❌ iCloud restricted")
//          case .couldNotDetermine:
//              print("⚠️ Could not determine iCloud status")
//          case .temporarilyUnavailable:
//              print("⚠️ iCloud temporarily unavailable")
//          @unknown default:
//              print("⚠️ Unknown iCloud status")
//          }
//          
//          if let error = error {
//              print("❌ CloudKit error: \(error.localizedDescription)")
//          }
//      }
//    }
  
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
            PrimaryGlassButton(title: "Next", action: saveAndNext)
                .padding(.horizontal)
                .padding(.vertical)
                .disabled(!isNameFilled)
                .opacity(isNameFilled ? 1 : 0.5)
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
          if surveyManager == nil {
            surveyManager = SurveyManager(modelContext: modelContext)
        }
          //checkCloudKitStatus()
      }
    }
}

#Preview {
    SurveyBirthdayView(onNext: {})
}

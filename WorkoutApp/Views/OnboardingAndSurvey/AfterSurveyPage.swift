//
//  AfterSurveyView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 17/11/25.
//

import SwiftUI

struct AfterSurveyView: View {
    @EnvironmentObject var router: Router
    
    var userName: String = "........"         // dari survey
    var phaseText: String = "Menstrual Phase" // dari survey
    var levelText: String = "Beginner Level"  // dari survey
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundPink()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // MARK: - Character
                    CharLogin()
                        .frame(height: 300)
                    
                    // MARK: - Title Section
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("Hey, \(userName)!")
                            .font(.largeTitle.bold())
                            .foregroundColor(Color("pinkTextPrimary"))
                        
                        (
                            Text("You’re in your ")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                            +
                            Text(phaseText)
                                .foregroundColor(Color("pinkTextPrimary"))
                                .fontWeight(.bold)
                            +
                            Text(", you’re starting at the ")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                            +
                            Text(levelText)
                                .foregroundColor(Color("pinkTextPrimary"))
                                .fontWeight(.bold)
                            +
                            Text(". We’ll guide you consistency and confidence!")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                        )
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.trailing, 12)
                    }
                    .padding(.horizontal)

                    
                    Spacer()
                    
                    // MARK: - Button
                    PrimaryGlassButton(title: "Okay") {
                        router.navigateTo(.menu)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .padding()
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    AfterSurveyView()
        .environmentObject(Router())
}

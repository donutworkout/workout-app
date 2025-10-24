//
//  SurveyView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI

struct SurveyView: View {
    @EnvironmentObject var router: Router
    @State private var currentPage = 0
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                Spacer()
                
                // MARK: - Survey Pages
                Group {
                    switch currentPage {
                    case 0:
                        SurveyBirthdayView(onNext: { currentPage += 1 })
                    case 1:
                        SurveyBodyInfoView(onNext: { currentPage += 1 })
                    case 2:
                        SurveyMotivationView(onNext: { currentPage += 1 })
                    case 3:
                        SurveyWorkoutLevelView(onNext: { currentPage += 1 })
                    case 4:
                        WorkoutDayView(onNext: { currentPage += 1 })
                    case 5:
                        SurveyCycleView(onFinish: {
                            router.navigateTo(.home)
                        })
                    default:
                        Text("Selesai ✅")
                    }
                }
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
            }
            
            // MARK: - Top Navigation Buttons
            HStack {
                if currentPage > 0 {
                    Button(action: {
                        withAnimation {
                            currentPage -= 1
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                            )
                    }
                } else {
                    Button(action: {
                        router.navigateTo(.onboarding)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                            )
                    }
                }
                
                Spacer()
            }
            .padding(.top, 20) // jarak dari atas biar nggak mepet
            .padding(.leading, 20) // jarak dari kiri biar rapi
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    SurveyView()
}

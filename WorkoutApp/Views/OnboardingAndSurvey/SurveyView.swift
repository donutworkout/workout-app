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
        VStack {
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
    }
}

#Preview {
    SurveyView()
}

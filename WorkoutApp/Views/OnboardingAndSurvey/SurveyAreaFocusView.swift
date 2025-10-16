//
//  SurveyAreaFocusView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI

struct SurveyAreaFocusView: View {
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Survey Area Focus View")
                .font(.title2)
            
            Button("Next") {
                onNext()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    SurveyAreaFocusView(onNext: {})
}

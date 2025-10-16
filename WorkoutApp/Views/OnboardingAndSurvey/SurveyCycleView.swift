//
//  SurveyCycleView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI

struct SurveyCycleView: View {
    var onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Survey Cycle View")
                .font(.title2)
            
            Button("Finish") {
                onFinish()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}


#Preview {
    SurveyCycleView(onFinish: {})
}

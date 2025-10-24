//
//  SurveyProgressText.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 24/10/25.
//

import SwiftUI

struct SurveyProgressText: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        Text("\(currentPage)/\(totalPages)")
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(Color("pinkTextPrimary"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
}

#Preview {
    SurveyProgressText(currentPage: 1, totalPages: 6)
}

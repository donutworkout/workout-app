//
//  PageControl.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 20/10/25.
//

import SwiftUI

struct PageControl: View {
    var totalPages: Int
    var currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.primary: Color.primary.opacity(0.3))
                    .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                    .animation(.easeInOut(duration: 0.25), value: currentPage)
            }
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    VStack {
        Spacer()
        PageControl(totalPages: 5, currentPage: 2)
    }
    .background(Color.white)
}


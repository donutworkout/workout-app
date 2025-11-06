//
//  WatchCountdownView.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 04/11/25.
//

import SwiftUI


struct WatchCountdownView: View {
    let count: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Get Ready!")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text("\(count)")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(Color("pinkTextPrimary"))
                .transition(.scale.combined(with: .opacity))
                .id(count)
        }
        .onAppear {
            WKInterfaceDevice.current().play(.notification)
        }
        
    }
}


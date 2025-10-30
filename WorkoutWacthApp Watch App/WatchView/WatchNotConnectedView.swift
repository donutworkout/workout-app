//
//  WatchNotConnected.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 28/10/25.
//

import SwiftUI

struct WatchNotConnectedView: View {
    @Environment var connectivity: WatchConnectivityManager
        
        var body: some View {
            VStack(spacing: 16) {
                Image(systemName: "iphone.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                
                Text("Phone Not Connected")
                    .font(.headline)
                
                Text("Open the app on your iPhone to select a workout")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Button("Retry") {
                    connectivity.requestTodayWorkout()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
}


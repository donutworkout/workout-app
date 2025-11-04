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
            VStack(spacing: 12) {
                if connectivity.isReachable {
                    Image(systemName: "iphone")
                        .font(.system(size: 28))
                        .foregroundStyle(.green)
                        .symbolEffect(.pulse, options: .repeating)
                    
                    Text("Find workouts\nfrom your phone")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .foregroundStyle(.secondary)
                    
                    Text("Open the app on your iPhone to choose a workout.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 4)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "iphone.slash")
                            .font(.system(size: 26))
                            .foregroundStyle(.gray)
                        
                        Text("Watch not connected")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("Please check Bluetooth or open the app on your iPhone.")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 4)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color.black.ignoresSafeArea())
        }
}


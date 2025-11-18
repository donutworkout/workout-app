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
                Image(systemName: "iphone.gen1.badge.play")
                    .font(.system(size: 42, weight: .regular))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .padding(.bottom, 4)
                
                Text("Open the workout\non your phone")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .lineSpacing(2)
                    .multilineTextAlignment(.center)
            } else {
                Image(systemName: "iphone.gen1.badge.exclamationmark")
                    .font(.system(size: 42, weight: .regular))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .padding(.bottom, 4)
                
                Text("Watch not connected")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .multilineTextAlignment(.center)
                
                Text("Please open the app on\nyour phone")
                    .font(.system(size: 14))
                    .foregroundColor(Color("pinkTextPrimary").opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
}


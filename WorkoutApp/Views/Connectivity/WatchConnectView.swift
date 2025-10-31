//
//  ConnectWatchView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 28/10/25.
//

import SwiftUI

struct ConnectWatchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    
    var onAllow: () -> Void = {}
    var onSkip: () -> Void = {}
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer()
                
                // MARK: - Title Text
                Text("Connect your watch to track your moves effortlessly")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // MARK: - Watch Icon Box
                ZStack {
                    Image(systemName: "applewatch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color("pinkTextPrimary"))
                }
                .padding(.top, 10)
                
                Spacer()
                
                // MARK: - Allow Button
                PrimaryGlassButton(title: "Allow") {
                    onAllow()
                }
                .padding(.horizontal)
                
                // MARK: - Skip Button
                Button(action: onSkip) {
                    Text("No, Thanks")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)
            }
            .background(Color.white.ignoresSafeArea())
            
            // MARK: - Navigation Title & Toolbar
            .navigationTitle("Watch Connect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Close Button (X)
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { router.navigateTo(.menu) }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                
            }
        }
    }
}

#Preview {
    ConnectWatchView()
}

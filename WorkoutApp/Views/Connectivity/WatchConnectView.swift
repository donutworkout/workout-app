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
    @State private var jump = false

    
    var onAllow: () -> Void = {}
    var onSkip: () -> Void = {}
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
//                Spacer()
                
                // MARK: - Title Text
                Text("Connect your watch to track your moves effortlessly")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
                
                // MARK: - Watch Icon Box
                ZStack {
                    Image("charConnectWatch")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .offset(y: jump ? -35 : 0)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                            ) {
                                jump = true
                            }
                        }
                }
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
                    Button(action: { router.navigateTo(.onboarding) }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    jump = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                        jump = false
                    }
                }
            }
        }
    }
}

#Preview {
    ConnectWatchView()
}

//
//  HealthConnectView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 28/10/25.
//

import SwiftUI

struct HealthConnectView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    
    var onAllow: () -> Void = {}
    var onSkip: () -> Void = {}
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer()
                
                // MARK: - Title Text
                Text("Automatically track your health metrics")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // MARK: - Heart Icon Box
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 3)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
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
            .navigationTitle("Health Connect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Default Close Button (X)
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { router.navigateTo(.onboarding) }) {
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
    HealthConnectView()
}

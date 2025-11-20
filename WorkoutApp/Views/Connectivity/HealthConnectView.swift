//
//  HealthConnectView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 28/10/25.
//

import SwiftUI
import HealthKit

struct HealthConnectView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    @State private var pulse = false

    
    var onAllow: () -> Void = {}
    var onSkip: () -> Void = {}
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
//                Spacer()
                
                // MARK: - Title Text
                Text("Automatically track your health metrics")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
                
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
                        .foregroundColor(Color.pink)     // warna pink solid
                        .scaleEffect(pulse ? 1.08 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                            value: pulse
                        )
                }
                .padding(.top, 10)
                
                Spacer()
                
                // MARK: - Allow Button
                PrimaryGlassButton(title: "Allow") {
                    HealthKitManager.shared.requestAuthorization()
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
            .onAppear {
                pulse = true
            }

        }
    }
}

#Preview {
    HealthConnectView()
}

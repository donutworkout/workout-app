//
//  HealthConnectView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 28/10/25.
//

import HealthKit
import SwiftUI

struct HealthConnectView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    @State private var pulse = false
    @AppStorage("finishedHealthOnboarding") var finishedHealthOnboarding = false

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
                
                // MARK: - Heart Icon Box (lebih kecil & animasi smooth)
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(
                            color: .gray.opacity(0.2),
                            radius: 8,
                            x: 0,
                            y: 3
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color.pink)
                        .scaleEffect(pulse ? 1.12 : 1.0)
                        .animation(.easeInOut(duration: 0.22), value: pulse)
                }
                .padding(.top, 10)

                Spacer()

                // MARK: - Allow Button
                PrimaryGlassButton(title: "Allow") {
                    iPhoneHealthKitManager.shared.requestAuthorization {
                        success,
                        error in
                        finishedHealthOnboarding = true
                        DispatchQueue.main.async {
                            onAllow()
                        }
                    }
                }
                .padding(.horizontal)

                // MARK: - Skip Button
                Button {
                    finishedHealthOnboarding = true
                    onSkip()
                } label: {
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
                startHeartbeat()
            }
        }
    }
    
    // Heartbeat lebih smooth (scale kecil, timing smooth)
    private func startHeartbeat() {
        Timer.scheduledTimer(withTimeInterval: 1.1, repeats: true) { _ in
            withAnimation { pulse = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                withAnimation { pulse = false }
            }
        }
    }
}

#Preview {
    HealthConnectView()
}

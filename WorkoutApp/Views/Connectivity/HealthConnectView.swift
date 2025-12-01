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
    
    @State private var showCustomAlert = false // untuk menampilkan alert
    
    var onAllow: () -> Void = {}
    var onSkip: () -> Void = {}
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Konten utama
                VStack(spacing: 32) {
                    Text("Automatically track your health metrics")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color("pinkTextPrimary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                    
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
                    
                    PrimaryGlassButton(title: "Allow") {
                        iPhoneHealthKitManager.shared.requestAuthorization { success, error in
                            finishedHealthOnboarding = true
                            DispatchQueue.main.async {
                                onAllow()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Button {
                        HapticManager.shared.trigger(.alertAppear)
                        withAnimation(.spring()) {
                            showCustomAlert = true
                        }
                    } label: {
                        Text("No, Thanks")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 40)
                }
                .background(Color.white.ignoresSafeArea())
                .blur(radius: showCustomAlert ? 3 : 0) // efek blur saat alert muncul
                .allowsHitTesting(!showCustomAlert)    // disable klik utama saat alert tampil
                
                // Alert overlay di atas
                if showCustomAlert {
                    ZStack {
                        Color.white.opacity(0.5)
                            .ignoresSafeArea(.all)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    showCustomAlert = false
                                }
                            }
                        
                        VStack(spacing: 0) {
                            VStack(spacing: 12) {
                                Text("Reminder")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                
                                Text("You can enable health tracking later before starting a workout. Some features may require it to start.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(nil)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                            
                            Divider()
                            
                            Button(action: {
                                finishedHealthOnboarding = true
                                onSkip()
                                withAnimation(.spring()) {
                                    showCustomAlert = false
                                }
                            }) {
                                Text("OK")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color("pinkTextPrimary"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .contentShape(Rectangle())
                            }
                        }
                        .frame(width: 270)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 1.1)))
                    .zIndex(999)
                }
            }
            .navigationTitle("Health Connect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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

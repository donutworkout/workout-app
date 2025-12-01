//
//  HealthNotConnectedView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 25/11/25.
//

import SwiftUI

struct HealthNotConnectedView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    
    var isHealthConnected: Bool
    var isWatchConnected: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.18).ignoresSafeArea()
            
            VStack {
//                Spacer()
                
                VStack(spacing: 32) {
                    // Handle indicator
//                    Capsule()
//                        .fill(Color.gray.opacity(0.3))
//                        .frame(width: 46, height: 5)
//                        .padding(.top, 12)
                    
                    // ✅ Section Health - hanya muncul jika !isHealthConnected
                    if !isHealthConnected {
                        VStack(spacing: 14) {
                            Text("Health Not Connected")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                            
                            Text("Apple Health access is required to track your health metrics automatically.")
                                .font(.system(size: 15))
                                .foregroundColor(.black.opacity(0.75))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            PrimaryGlassButton(title: "Open Health Settings") {
                                if let url = URL(string: "App-Prefs:root=General") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .padding(.top, 6)
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 21)
                    }
                    
                    // ✅ Divider - hanya muncul jika KEDUA section tampil
                    if !isHealthConnected && !isWatchConnected {
                        Divider()/*.padding(.vertical)*/
                    }
                    
                    // ✅ Section Watch - hanya muncul jika !isWatchConnected
                    if !isWatchConnected {
                        VStack(spacing: 14) {
                            Text("Watch Not Connected")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                            
                            Text("Make sure your Apple Watch is connected via Bluetooth for workout syncing.")
                                .font(.system(size: 15))
                                .foregroundColor(.black.opacity(0.75))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            PrimaryGlassButton(title: "Open Bluetooth Settings") {
                                if let url = URL(string: "App-Prefs:") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .padding(.top, 6)
                        }
                        .padding(.horizontal, 28)
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(.top, 25)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.11), radius: 16, x: 0, y: -2)
                )
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                Button(action: { dismiss() }) {
//                    Image(systemName: "xmark")
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(.black)
//                }
//            }
//        }
    }
}

//
//  HealthNotConnectedView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 25/11/25.
//

import SwiftUI
import HealthKit

struct HealthNotConnectedView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    @State private var pulse = false
    
    var onConnect: () -> Void = {}
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
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
                
                Spacer()
                
                // MARK: - Description Text
                Text("HeyLoona! integrates with Apple Health to automatically track your health metrics")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
                
                // MARK: - Instructions Text
                Text("To manage access permissions to Health, please tap Open Settings > Health > Data Access & Devices > HeyLoona!")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                
                // MARK: - Open Settings Button
                PrimaryGlassButton(title: "Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .background(Color.white.ignoresSafeArea())
            
            // MARK: - Navigation Title & Toolbar
            .navigationTitle("Health Connect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
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
    HealthNotConnectedView()
}

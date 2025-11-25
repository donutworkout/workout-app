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
            VStack(spacing: 28) {
                Spacer()
                // Heart Icon Box - lebih kecil dan smooth beat
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.18), radius: 6, x: 0, y: 2)
                        .frame(width: 78, height: 78)    // ukuran diperkecil
                    
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                        .foregroundColor(.pink)
                        .scaleEffect(pulse ? 1.12 : 1.0)
                        .animation(.easeInOut(duration: 0.22), value: pulse)  // beat smooth & natural
                }
                
                Spacer()
                
                // Description Text
                Text("HeyLoona! integrates with Apple Health to automatically track your health metrics.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 26)
                    .fixedSize(horizontal: false, vertical: true)  // mencegah terpotong
                
                // Instructions Text
                Text("To manage access permissions to Health, tap Open Settings, then go to Health > Data Access & Devices > HeyLoona!")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 26)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Open Settings Button
                PrimaryGlassButton(title: "Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 34)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("Health Connect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
            }
            .onAppear {
                startHeartbeat()
            }
        }
    }
    
    // Heartbeat lebih smooth (pause lebih lama dan scale lebih kecil)
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
    HealthNotConnectedView()
}

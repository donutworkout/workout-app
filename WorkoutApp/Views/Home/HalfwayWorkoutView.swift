//
//  HalfwayWorkoutView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 06/11/25.
//

import SwiftUI

struct HalfwayWorkoutView: View {
    @EnvironmentObject var router: Router
    @Environment(iPhoneConnectivityManager.self) private var connectivity
    
    var characterImage: String = "charHalfwayDone"
    

    // Tambahkan state untuk animasi
    @State private var characterScale: CGFloat = 0.7
    @State private var characterOpacity: Double = 0.0
    
    func formatTime(_ seconds: Double) -> String {
        let s = Int(seconds)
        let h = s / 3600
        let m = (s % 3600) / 60
        let sec = s % 60
        return String(format: "%02d:%02d:%02d", h, m, sec)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // MARK: - Character dengan animasi
            Image(characterImage)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .scaleEffect(characterScale)
                .opacity(characterOpacity)
                .animation(.spring(response: 0.6, dampingFraction: 0.65, blendDuration: 0.2), value: characterScale)
                .animation(.easeOut(duration: 0.6), value: characterOpacity)
            
            // MARK: - Title
            VStack(spacing: 6) {
                Text("HALFWAY DONE!")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color("pinkTextPrimary"))
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            
            // MARK: - Summary Card
            VStack(spacing: 12) {
                HStack {
                    summaryItem(title: "Workout Time", value: formatTime(connectivity.summaryDuration))
                    Divider()
                    summaryItem(title: "Active Kilocalories", value: "\(Int(connectivity.summaryActiveEnergy)) kcal")
                }
                Divider()
                HStack {
                    summaryItem(title: "Total Calories", value: "\(Int(connectivity.summaryTotalEnergy)) kcal")
                    Divider()
                    summaryItem(title: "Avg. Heart Rate", value: "\(Int(connectivity.summaryAvgHeartRate)) bpm")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            Spacer()
            
            // MARK: - Done Button
            PrimaryGlassButton(title: "Done") {
                router.navigateTo(.menu)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            HapticManager.shared.trigger(.workoutCompleted)
            characterScale = 1.18
            characterOpacity = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    characterScale = 1.0
                }
            }
        }
    }
    
    // MARK: - Reusable Summary Item
    @ViewBuilder
    func summaryItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        HalfwayWorkoutView()
            .environmentObject(Router())
    }
}

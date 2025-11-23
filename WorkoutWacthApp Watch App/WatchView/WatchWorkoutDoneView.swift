//
//  WatchWorkoutDoneView.swift
//  WorkoutWatchApp Watch App
//
//  Created by Jennifer Evelyn on 05/11/25.
//

import SwiftUI

struct WatchWorkoutDoneView: View {
    @Environment(WorkoutSessionManager.self) private var sessionManager

    @State private var elapsedTime: Int = 302  // contoh: 5 menit 2 detik (bisa diganti dari parent view)
    @State private var currentTime: String = Self.formatCurrentTime()
    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        ZStack {
            Color("grayBackground")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Image("charCongrats")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)

                    Text("Congratulations!")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.white)
                }
                .padding(.top, -20)

                // MARK: - Static Stats
                VStack(alignment: .leading, spacing: 0) {
                    statRow(
                        icon: "clock.fill",
                        value: formatTime(Int(sessionManager.timeActive)),
                        label: "Duration"
                    )

                    statRow(
                        icon: "flame.fill",
                        value: String(
                            format: "%.0f kcal",
                            sessionManager.activeEnergy
                        ),
                        label: "Active Energy"
                    )

                    statRow(
                        icon: "figure.walk",
                        value: formatDistance(sessionManager.distance),
                        label: "Distance"
                    )

                    statRow(
                        icon: "heart.fill",
                        value: String(
                            format: "%.0f bpm",
                            sessionManager.heartRate
                        ),
                        label: "Avg Heart Rate"
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.top, 2)

                Spacer()
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: - Format Helpers
    private static func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    // MARK: - Reusable Row
    @ViewBuilder
    private func statRow(icon: String, value: String, label: String)
        -> some View
    {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color("pinkTextPrimary"))
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    // MARK: - Update Real Clock Only
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        currentTime = formatter.string(from: Date())
    }
    
    // MARK: - Formating Distance
    
    private func formatDistance(_ meters: Double) -> String {
           if meters >= 1000 {
               return String(format: "%.2f km", meters / 1000)
           } else {
               return String(format: "%.0f m", meters)
           }
       }

    private func formatTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

#Preview("Done") {
    WatchWorkoutDoneView()
}

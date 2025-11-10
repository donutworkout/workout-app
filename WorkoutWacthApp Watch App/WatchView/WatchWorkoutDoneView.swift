//
//  WatchWorkoutDoneView.swift
//  WorkoutWatchApp Watch App
//
//  Created by Jennifer Evelyn on 05/11/25.
//

import SwiftUI

struct WatchWorkoutDoneView: View {
    // Timer tidak lagi berjalan — hanya menampilkan waktu akhir.
    @State private var elapsedTime: Int = 302 // contoh: 5 menit 2 detik (bisa diganti dari parent view)
    @State private var currentTime: String = Self.formatCurrentTime()
    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color("grayBackground")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Bar
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "figure.run")
                            .font(.system(size: 18))
                            .foregroundColor(Color("pinkTextPrimary"))
                    }

                    Spacer()

                    // Tetap update jam di kanan atas
                    Text(currentTime)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .onReceive(clockTimer) { _ in updateTime() }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)

                Spacer()

                // MARK: - Character & Congratulations
                VStack(spacing: 0) {
                    Image("buttercup")
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
                    // Timer (statis, tidak jalan)
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color("pinkTextPrimary"))
                        Text(formatTime(elapsedTime))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color("pinkTextPrimary"))
                        Text("19 kcal")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 16))
                            .foregroundColor(Color("pinkTextPrimary"))
                        Text("6.2 km")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color("pinkTextPrimary"))
                        Text("95 bpm")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.top, 2)

                Spacer()
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: - Update Real Clock Only
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        currentTime = formatter.string(from: Date())
    }

    // MARK: - Format Helpers
    private static func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
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

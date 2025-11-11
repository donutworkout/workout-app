//
//  WatchWorkoutStrengthView.swift
//  WorkoutWatchApp Watch App
//
//  Created by Jennifer Evelyn on 05/11/25.
//

// page 2 dari start stop, page 1 nya di WatchWorkoutControlView

import SwiftUI

struct WatchWorkoutStrengthView: View {
    @State private var elapsedTime: Int = 0
    @State private var currentTime: String = Self.formatCurrentTime()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
                    
                    Text(currentTime)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .onReceive(timer) { _ in updateTime() }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                
                Spacer()

                // MARK: - Character
                Image("buttercup") // pastikan asset sama
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.top, -20)

                // MARK: - Timer + Stats
                VStack(alignment: .leading, spacing: 0) {
                    // Timer tampil jam:menit:detik
                    Text(formatTime(elapsedTime))
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.bottom, 4)

                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color("pinkTextPrimary"))
                        Text("19 kcal")
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
                .padding(.top, 10)

                Spacer()
                .padding(.bottom, 20)
            }
        }
        .onReceive(timer) { _ in
            elapsedTime += 1
        }
        .onAppear {
            // Reset or continue as desired; keeping current value
        }
        .onDisappear {
            // No-op here; the autoconnected timer will stop delivering when view is gone
        }
    }

    // MARK: - Update Time
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        currentTime = formatter.string(from: Date())
    }
    
    // MARK: - Format Functions
    private static func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    private func formatTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        // Selalu tampil jam:menit:detik (00:00:00)
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

#Preview("Stats") {
    WatchWorkoutStrengthView()
}

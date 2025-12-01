//
//  WatchWorkoutDoneView.swift
//  WorkoutWatchApp Watch App
//
//  Created by Jennifer Evelyn on 05/11/25.
//

import SwiftUI
import HealthKit

struct WatchWorkoutDoneView: View {
    @Environment(WatchConnectivityManager.self) private var connectivity
    @Environment(WorkoutSessionManager.self) private var sessionManager
    
    let workoutType: HKWorkoutActivityType
    
    @State private var elapsedTime: Int = 302
    @State private var currentTime: String = Self.formatCurrentTime()
    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    @Binding var showDoneView: Bool


    var body: some View {
        ZStack {
            Color("grayBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        endAndDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 6)
                VStack(spacing: 0) {
                    Image("charCongrats")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)

                    Text("Congratulations!")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.white)
                }

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
                    if shouldShowDistance(for: workoutType) {
                        statRow(
                            icon: "figure.walk",
                            value: formatDistance(sessionManager.distance),
                            label: "Distance"
                        )
                    }

                    statRow(
                        icon: "heart.fill",
                        value: String(
                            format: "%.0f bpm",
                            sessionManager.averageHeartRate
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

    private func endAndDismiss() {
        connectivity.selectedWorkoutType = nil
        connectivity.shouldStartWorkout = false
        showDoneView = false
    }
    
    private func shouldShowDistance(for type: HKWorkoutActivityType) -> Bool {
        switch type {
        case .running, .walking, .cycling, .swimming:
            return true
        default:
            return false
        }
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

//#Preview("Done") {
//    WatchWorkoutDoneView(showDoneView: Binding<Bool>)
//}

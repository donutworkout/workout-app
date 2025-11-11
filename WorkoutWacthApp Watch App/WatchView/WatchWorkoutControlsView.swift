//
//  WatchWorkoutControlsView.swift
//  WorkoutWatchApp Watch App
//
//  Created by Jennifer Evelyn on 04/11/25.
//

// page 1 yang start stop, page 2 nya di WatchWorkoutStatsView

import SwiftUI

struct WatchWorkoutControlsView: View {
    @State private var currentTime: String = ""
    @State private var isPaused: Bool = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView {
            // MARK: - Page 1: Controls
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
                
                // MARK: - Control Buttons
                VStack(spacing: 12) {
                    PrimaryGlassButton(title: isPaused ? "RESUME" : "PAUSE", icon: isPaused ? "play.fill" : "pause.fill") {
                        isPaused.toggle()
                        print(isPaused ? "Resume tapped" : "Pause tapped")
                    }
                    .frame(height: 50)
                    
                    NeutralGlassButton(title: "STOP", icon: "stop.fill") {
                        print("Stop tapped")
                    }
                    .frame(height: 50)
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .padding(.bottom, 20)
            .background(Color("grayBackground"))
            .ignoresSafeArea()
            
            // MARK: - Page 2: Stats
            WatchWorkoutCardioView()
                .background(Color("grayBackground"))
                .ignoresSafeArea()
            
//            WatchWorkoutStrengthView()
//                .background(Color("grayBackground"))
//                .ignoresSafeArea()
        }
        .tabViewStyle(.page)
        .onAppear { updateTime() }
    }
    
    // MARK: - Update Time
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        currentTime = formatter.string(from: Date())
    }
}

#Preview("Controls") {
    WatchWorkoutControlsView()
}

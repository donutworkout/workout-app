//
//  StartCardioView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 27/10/25.
//

import SwiftUI

struct StartCardioView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Props
    var activityName: String = "Indoor Walk"
    var imageName: String = "indoorWalk"
    
    @State private var timeElapsed: TimeInterval = 0
    @State private var calories: Int = 0
    @State private var bpm: Int = 90
    @State private var isPaused: Bool = false
    
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .padding(.top, 40)
            
            Spacer()
            
            // MARK: - Timer Card
            VStack(spacing: 8) {
                Text("Time")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Text(formattedTime)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color("pinkTextPrimary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.15), radius: 6, x: 0, y: 3)
            )
            .padding(.horizontal)
            
            // MARK: - Stats
            HStack(spacing: 16) {
                StatCard(title: "\(calories) KCAL", color: Color("pinkTextPrimary").opacity(0.25))
                StatCard(title: "❤️ \(bpm) BPM", color: Color("pinkTextPrimary").opacity(0.25))
            }
            .padding(.horizontal)
            
            Spacer()
            
            // MARK: - Buttons
            HStack(spacing: 16) {
                Button(action: toggleTimer) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(.ultraThinMaterial))
                }
                
                PrimaryGlassButton(title: "Done") {
                    timer?.invalidate()
                    dismiss()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle(activityName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    timer?.invalidate()
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear { startTimer() }
        .onDisappear { timer?.invalidate() }
    }
    
    private var formattedTime: String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !isPaused {
                timeElapsed += 1
                calories = Int(timeElapsed / 15) // contoh sederhana
                bpm = 90 + Int(timeElapsed.truncatingRemainder(dividingBy: 30))
            }
        }
    }
    
    private func toggleTimer() {
        isPaused.toggle()
    }
}

#Preview {
    NavigationStack {
        StartCardioView()
    }
}

//
//  StartStrengthView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 27/10/25.
//

import SwiftUI

struct StartStrengthView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    
    var workoutName: String = "Bridge"
    var reps: String = "3 x 12"
    var imageName: String = "bridge"
    
    @State private var timeElapsed: TimeInterval = 0
    @State private var isPaused: Bool = false
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 320)
                .padding(.top, 40)
            
            Spacer()
            
            VStack(spacing: 12) {
                Text(workoutName)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(Color("pinkTextPrimary"))
                
                Text(formattedTime)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .padding(.top, 8)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                NeutralGlassButton(title: isPaused ? "Resume" : "Pause") {
                    toggleTimer()
                }
                
                NeutralGlassButton(title: "Next") {
                    timer?.invalidate()
                    router.navigateTo(.menu)
                }
            }
            .padding(.bottom, 40)
            .padding(.horizontal)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    timer?.invalidate()
                    router.navigateTo(.menu)
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
            }
        }
    }
    
    private func toggleTimer() {
        isPaused.toggle()
    }
}


#Preview {
    NavigationStack {
        StartStrengthView()
    }
}

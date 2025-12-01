//
//  WatchCountdownView.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 04/11/25.
//

import SwiftUI

struct WatchCountdownView: View {
    let count: Int
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // MARK: - Get Ready Text
            Text("Get Ready!")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .textCase(.uppercase)
                .tracking(1)
                .padding(.bottom, 24)
            
            // MARK: - Countdown Number with Circle
            ZStack {
                // Outer pulsing circle
                Circle()
                    .stroke(Color("pinkTextPrimary").opacity(0.3), lineWidth: 3)
                    .frame(width: 120, height: 120)
                
                // Inner filled circle
                Circle()
                    .fill(Color("pinkTextPrimary").opacity(0.15))
                    .frame(width: 100, height: 100)
                
                // Number
                Text("\(count)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(Color("pinkTextPrimary"))
                    .monospacedDigit()
            }
            .scaleEffect(scale)
            .opacity(opacity)
            
            Spacer()
            
            // MARK: - Bottom Hint
            Text("Starting workout...")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            WKInterfaceDevice.current().play(.notification)
            
            // Entrance animation
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
        .onChange(of: count) { _, _ in
            // Reset and animate on count change
            scale = 0.8
            opacity = 0.5
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Haptic feedback
            WKInterfaceDevice.current().play(.click)
        }
    }
}

#Preview {
    WatchCountdownView(count: 3)
}

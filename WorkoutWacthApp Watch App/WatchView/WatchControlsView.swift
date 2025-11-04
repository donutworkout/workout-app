//
//  WatchControlsView.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 03/11/25.
//

import SwiftUI

struct WatchControlsView: View {
    @Environment var sessionManager: WorkoutSessionManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack(spacing: 20) {
            Button {
                // TODO: Toggle play/pause on the session manager
                // Example: sessionManager.toggleRunning()
            } label: {
                Image(systemName: sessionManager.isRunning ? "pause.fill" : "play.fill")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
            
            Button {
                sessionManager.stopWorkout()
                dismiss()
            } label: {
                Image(systemName: "stop.fill")
                    .font(.title2)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // If needed, start your workout or timer here.
            // Example: sessionManager.startWorkout(of: someWorkoutType)
        }
        .onDisappear {
            // If needed, stop timers or clean up here.
        }
    }
}

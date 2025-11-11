////
////  WatchControlsView.swift
////  WorkoutApp
////
////  Created by Valencia Melita Christy on 03/11/25.
////
//
//import SwiftUI
//
//struct WatchControlsView: View {
//    @Environment var sessionManager: WorkoutSessionManager
//    @Environment var connectivity: WatchConnectivityManager
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        HStack(spacing: 20) {
//            Button {
//                if sessionManager.isRunning {
//                    sessionManager.pauseWorkout()
//                    connectivity.sendMessage([
//                        "cmd": WorkoutCommand.pause.rawValue
//                    ])
//                } else {
//                    //sessionManager.resumeWorkout()
//                    connectivity.sendMessage([
//                        "cmd": WorkoutCommand.resume.rawValue
//                    ])
//                }
//            } label: {
//                VStack(spacing: 8) {
//                    Image(
//                        systemName: sessionManager.isRunning
//                            ? "pause.circle.fill" : "play.circle.fill"
//                    )
//                    .font(.system(size: 50))
//                    .foregroundColor(Color("pinkTextPrimary"))
//
//                    Text(sessionManager.isRunning ? "Pause" : "Resume")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.white)
//                }
//            }
//            .buttonStyle(.bordered)
//
//            Button {
//                sessionManager.stopWorkout()
//                connectivity.sendMessage([
//                    "cmd": WorkoutCommand.stop.rawValue
//                ])
//                
//                dismiss()
//            } label: {
//                VStack(spacing: 8) {
//                    Image(systemName: "xmark.circle.fill")
//                        .font(.system(size: 50))
//                        .foregroundColor(.red)
//
//                    Text("End")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.white)
//                }
//            }
//            .buttonStyle(PlainButtonStyle())
//            .tint(.red)
//        }
//        .padding()
//        .navigationBarBackButtonHidden(true)
//        .onAppear {
//            // If needed, start your workout or timer here.
//            // Example: sessionManager.startWorkout(of: someWorkoutType)
//        }
//        .onDisappear {
//            // If needed, stop timers or clean up here.
//        }
//    }
//}

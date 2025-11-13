//
//  WatchConnectivityManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 15/10/25.
//

import Combine
import Foundation
import HealthKit
import WatchConnectivity

enum WorkoutCategory: String {
    case cardio
    case strength
}

@Observable
class WatchConnectivityManager: NSObject {
    static let shared = WatchConnectivityManager()
    private let sessionManager = WorkoutSessionManager.shared

    private let session = WCSession.default
    var selectedWorkoutType: HKWorkoutActivityType? = nil

    var phoneReady = false
    var shouldStartWorkout = false
    var isReachable: Bool = false

    private var lastMetricsSent: Date = .distantPast
    
    override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        guard WCSession.isSupported() else {
            print("gak support")
            return
        }
        session.delegate = self
        session.activate()
        isReachable = session.isReachable
    }

    func sendMessage(_ message: [String: Any]) {
        guard session.activationState == .activated else {
            print("❌ Session not activated")
            return
        }
        if session.isReachable {
            if let cmd = message["cmd"] as? String {
                if cmd == WorkoutCommand.start.rawValue {
                    shouldStartWorkout = true
                }
            }
            print("message: \(message["cmd"] ?? "nil")")
            session.sendMessage(
                message,
                replyHandler: { reply in
                    print("✅ Reply received: \(reply)")
                },
                errorHandler: { error in
                    print("error nihh: \(error)")
                }
            )
        } else {
            print("⚠️ Session not reachable, queueing via transferUserInfo")
            session.transferUserInfo(message)
        }
    }
    
    func sendMetrics(heartRate: Double, energy: Double, distance: Double, elapsed: Double) {
        let now = Date()
        guard now.timeIntervalSince(lastMetricsSent) > 2 else { return } // tiap 1 detik
        lastMetricsSent = now

        guard session.activationState == .activated else {
            print("⚠️ WCSession not activated")
            return
        }

        guard session.isReachable else {
            print("📡 iPhone not reachable — skipping metrics this tick")
            return
        }

        let message: [String: Any] = [
            "cmd": "updateMetrics",
            "heartRate": heartRate,
            "energy": energy,
            "distance": distance,
            "time": elapsed
        ]

        session.sendMessage(message, replyHandler: nil) { error in
            print("⚠️ sendMessage failed: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        print("📬 Received background message: \(userInfo)")
        handleIncomingMessage(userInfo)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any])
    {
        print("📩 Received message: \(message)")
        handleIncomingMessage(message)
    }
    
    private func handleIncomingMessage(_ message: [String: Any]) {
            DispatchQueue.main.async {
                if let typeRaw = message["selectedWorkout"] as? UInt,
                   let type = HKWorkoutActivityType(rawValue: typeRaw) {
                    self.selectedWorkoutType = type
                    print("✅ Updated selectedWorkoutType: \(type.displayName)")
                }
                if let cmdRaw = message["cmd"] as? String,
                   let cmd = WorkoutCommand(rawValue: cmdRaw) {
                    switch cmd {
                        
                    // iPhone → start
                    case .start:
                        if let typeRaw = message["workoutType"] as? UInt,
                           let type = HKWorkoutActivityType(rawValue: typeRaw) {
                            self.selectedWorkoutType = type
                            print("⌚ Received start command from iPhone: \(type.displayName)")
                            self.shouldStartWorkout = true
                        }
                        
                    case .pause:
                        self.sessionManager.pauseWorkout()
                        print("⏸️ Pause command executed on watch")

                    // iPhone → resume
                    case .resume:
                        self.sessionManager.resumeWorkout()
                        print("▶️ Resume command executed on watch")

                    // iPhone → stop
                    case .stop:
                        DispatchQueue.main.async {
                            self.shouldStartWorkout = false
                            self.sessionManager.stopWorkout()
                            print("🛑 Stop command executed on watch")

                        }

                    // Mirror confirmation from iPhone
                    case .started:
                        print("✅ iPhone confirmed workout started")
                    }
                }
            }
        }
    }



// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isReachable = session.isReachable
            if activationState == .activated {
                print("✅ Watch WCSession activated")
            } else if let error = error {
                print(
                    "❌ Watch WCSession activation error: \(error.localizedDescription)"
                )
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            if self.isReachable {
                print("watch session reachable")
            } else {
                print("watch session not reachable")
            }
        }
    }

    #if os(iOS)
        func sessionDidBecomeInactive(_ session: WCSession) {}
        func sessionDidDeactivate(_ session: WCSession) {
            session.activate()
        }
    #endif
}

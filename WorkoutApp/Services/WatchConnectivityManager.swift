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
    var selectedIsIndoor: Bool = false
    var selectedActivityName: String = ""

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
    
    func resetState() {
        // Reset connectivity-related transient flags
        shouldStartWorkout = false
        selectedWorkoutType = nil
        phoneReady = false
        isReachable = session.isReachable
        lastMetricsSent = .distantPast
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
            print("send message: \(message["cmd"] ?? "nil")")
            session.sendMessage(
                message,
                replyHandler: nil,
                errorHandler: { error in
                    print("error nihh: \(error)")
                }
            )
        } else {
            print("⚠️ Session not reachable, queueing via transferUserInfo")
            session.transferUserInfo(message)
        }
    }
    
    func sendMetrics(heartRate: Double, energy: Double, distance: Double) {
        let now = Date()
        guard now.timeIntervalSince(lastMetricsSent) >= 1 else { return }
        lastMetricsSent = now

        guard session.activationState == .activated else {
            print("⚠️ WCSession not activated")
            return
        }

        let payload: [String: Any] = [
            "cmd": "updateMetrics",
            "heartRate": heartRate,
            "energy": energy,
            "distance": distance
        ]

        print("📤 Sending metrics via transferUserInfo: \(payload)")
        session.transferUserInfo(payload)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        print("📬 Received background message: \(userInfo)")
        handleIncomingMessage(userInfo)
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        print("📩 Received message with reply: \(message)")
        handleIncomingMessage(message)
        replyHandler(["status": "received"])
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("📩 Received message: \(message)")
        handleIncomingMessage(message)
    }
    
    private func handleIncomingMessage(_ message: [String: Any]) {
            DispatchQueue.main.async {
                
                let selectedTypeRaw = message["selectedWorkout"] as? UInt
                let activityName = message["activityName"] as? String
                let isIndoorFromPhone = message["isIndoor"] as? Bool
                let cmdRaw = message["cmd"] as? String
                
                if let typeRaw = selectedTypeRaw,
                   let type = HKWorkoutActivityType(rawValue: typeRaw) {
                    self.selectedWorkoutType = type }
                if let name = activityName {
                    self.selectedActivityName = name }
                if let isIndoor = isIndoorFromPhone {
                    self.selectedIsIndoor = isIndoor }

                if let type = self.selectedWorkoutType {
                    print("✅ Updated selectedWorkoutType: \(type.displayName)") }
                if !self.selectedActivityName.isEmpty {
                    print("✅ Updated selectedActivityName: \(self.selectedActivityName)") }
    

                if let cmdRaw = cmdRaw, let cmd = WorkoutCommand(rawValue: cmdRaw) {
                    switch cmd {
                    
                    case .start:
                        if let typeRaw = message["workoutType"] as? UInt,
                            let type = HKWorkoutActivityType(rawValue: typeRaw) {

                             let isIndoor = message["isIndoor"] as? Bool ?? false
                             print("⌚ Received start command from iPhone: \(type.displayName), indoor? \(isIndoor)")

                             self.selectedWorkoutType = type
                             self.selectedIsIndoor = isIndoor  

                             self.sessionManager.timeActive = 0
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
                            self.resetState()
                            print("🛑 Stop command executed on watch")

                        }
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

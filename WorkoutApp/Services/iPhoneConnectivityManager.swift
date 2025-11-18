//
//  iPhoneConnectivityManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 16/10/25.
//

import Foundation
import HealthKit
import WatchConnectivity

@Observable
final class iPhoneConnectivityManager: NSObject {
    private let sessionManager = WorkoutSessionManager.shared
    static let shared = iPhoneConnectivityManager()

    private let session = WCSession.default
    var isWorkoutActive = false
    var isWorkoutPaused = false
    
    var summaryDuration: Double = 0
    var summaryActiveEnergy: Double = 0
    var summaryTotalEnergy: Double = 0
    var summaryDistance: Double = 0
    var summaryAvgHeartRate: Double = 0

    var heartRate: Double = 0
    var energyBurned: Double = 0
    var distance: Double = 0.0

    override init() {
        super.init()
        guard WCSession.isSupported() else {
            return
        }
        session.delegate = self
        session.activate()
    }
    
    func resetMetrics() {
        heartRate = 0
        energyBurned = 0
        distance = 0
        summaryDuration = 0
        summaryActiveEnergy = 0
        summaryTotalEnergy = 0
        summaryDistance = 0
        summaryAvgHeartRate = 0
        isWorkoutActive = false
        isWorkoutPaused = false
    }

}

extension iPhoneConnectivityManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if activationState == .activated {
                self.sendMessage(["phoneReady": true])
                print("ℹ️ Phone is ready to receive data.")
            }
            print("iPhone WCSession activated: \(activationState.rawValue)")
        }

    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        print("📱 iPhone received: \(message)")
        self.handleIncomingMessage(message)
        replyHandler(["status": "received"])
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("📱 iPhone received: \(message)")
        self.handleIncomingMessage(message)
    }

    func session(_ session: WCSession,didReceiveUserInfo userInfo: [String: Any]
    ) {
        DispatchQueue.main.async {
            print("📬 Received background message: \(userInfo)")
            self.handleIncomingMessage(userInfo)
        }
    }

}

extension iPhoneConnectivityManager {
    fileprivate func handleIncomingMessage(_ message: [String: Any]) {
        DispatchQueue.main.async {

            if let typeRaw = message["selectedWorkout"] as? UInt,
               let type = HKWorkoutActivityType(rawValue: typeRaw) {
                print("📌 iPhone received selectedWorkout → \(type.displayName)")
                self.isWorkoutActive = false
                self.isWorkoutPaused = false
                // Save so phone knows what to start
                self.sessionManager.timeActive = 0
                return
            }

            guard let cmd = message["cmd"] as? String else {
                print("⚠️ Incoming message WITHOUT CMD ignored: \(message)")
                return
            }

            print("📩 iPhone received CMD: \(cmd)")

            switch cmd {

            case WorkoutCommand.start.rawValue, "start":
                if let typeRaw = message["workoutType"] as? UInt,
                   let type = HKWorkoutActivityType(rawValue: typeRaw) {
                    print("📱 Start command → begin workout on iPhone")
                    self.isWorkoutActive = true
                    self.isWorkoutPaused = false
                    self.sessionManager.startWorkout(of: type)
                }

            case WorkoutCommand.pause.rawValue, "pause":
                self.isWorkoutPaused = true
                self.sessionManager.pauseWorkout()

            case WorkoutCommand.resume.rawValue, "resume":
                self.isWorkoutPaused = false
                self.sessionManager.resumeWorkout()

            case WorkoutCommand.stop.rawValue, "stop":
                self.isWorkoutActive = false
                self.isWorkoutPaused = false
                self.sessionManager.stopWorkout()

            case "updateMetrics":
                self.heartRate    = message["heartRate"] as? Double ?? 0
                self.energyBurned = message["energy"]     as? Double ?? 0
                self.distance     = message["distance"]   as? Double ?? 0
                print("📈 Metrics Updated")

            case "workoutSummary":
                self.summaryDuration      = message["duration"]     as? Double ?? 0
                self.summaryActiveEnergy  = message["activeEnergy"] as? Double ?? 0
                self.summaryTotalEnergy   = message["totalEnergy"]  as? Double ?? 0
                self.summaryDistance      = message["distance"]     as? Double ?? 0
                self.summaryAvgHeartRate  = message["avgHeartRate"] as? Double ?? 0
                print("📦 Summary received")

            default:
                print("⚠️ Unknown cmd: \(cmd)")
            }
        }
    }

}

extension iPhoneConnectivityManager {
    func sendMessage(_ data: [String: Any]) {
        guard session.activationState == .activated else {
            print("⚠️ WCSession is not activated.")
            return
        }
        guard session.isReachable else {
            print("⚠️ Session unreachable.")
            session.transferUserInfo(data)  // ✅ fallback
            return
        }

        session.sendMessage(data, replyHandler: nil) { error in
            print("❌ Error sending message: \(error.localizedDescription)")
        }
    }

    func sendSelectedWorkout(_ type: HKWorkoutActivityType) {
        guard session.activationState == .activated else {
            print("⚠️ WCSession not activated.")
            return
        }
        guard session.isReachable else {
            print("⚠️ Watch not reachable.")
            return
        }

        let message: [String: Any] = ["selectedWorkout": type.rawValue]
        session.sendMessage(message, replyHandler: nil) { error in
            print(
                "❌ Failed to send workout type: \(error.localizedDescription)"
            )
        }
        print("📤 Sent selected workout: \(String(describing: type))")
    }

    func startWorkoutFromPhone(type: HKWorkoutActivityType) {
        // If reachable -> watch owns session
        if session.isReachable {
            sendMessage(["cmd": "start", "workoutType": type.rawValue])
        } else {
            sessionManager.startWorkout(of: type)
            print("📱 Phone started workout locally (no watch reachable)")
        }
    }

    func pauseWorkoutFromPhone() {
        isWorkoutPaused = true
        if session.isReachable {
            sendMessage(["cmd": WorkoutCommand.pause.rawValue])
        } else {
            sessionManager.pauseWorkout()
        }
    }

    func resumeWorkoutFromPhone() {
        isWorkoutPaused = false
        if session.isReachable {
            sendMessage(["cmd": WorkoutCommand.resume.rawValue])
        } else {
            sessionManager.resumeWorkout()
        }
    }

    func stopWorkoutFromPhone() {
        if session.isReachable {
            sendMessage(["cmd": WorkoutCommand.stop.rawValue])
        }
        sessionManager.stopWorkout()
        isWorkoutActive = false
        isWorkoutPaused = false
        print("📱 User ended workout → notifying watch")
    }
}


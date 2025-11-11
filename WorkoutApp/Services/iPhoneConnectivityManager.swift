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
    private let sessionManager = WorkoutSessionManager()
    static let shared = iPhoneConnectivityManager()

    private let session = WCSession.default
    var isWorkoutActive = false
    var isWorkoutPaused = false

    var heartRate: Double = 0
    var energyBurned: Double = 0
    var distance: Double = 0
    var timeActive: Double = 0

    override init() {
        super.init()
        guard WCSession.isSupported() else {
            return
        }

        session.delegate = self
        session.activate()

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
        print("iphone received: \(message)")
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
            if let cmdRaw = message["cmd"] as? String,
                let cmd = WorkoutCommand(rawValue: cmdRaw)
            {
               print("iphone cmd received: \(cmd.rawValue)")
                switch cmd {
                case .start:
                    if let typeRaw = message["workoutType"] as? UInt,
                        let type = HKWorkoutActivityType(rawValue: typeRaw)
                    {

                        self.isWorkoutActive = true
                        self.isWorkoutPaused = false

                        if !self.sessionManager.isRunning {
                            self.sessionManager.startWorkout(of: type)
                        } else {
                            print(
                                "ℹ️ iPhone workout already running; ignoring duplicate start"
                            )
                        }
                    }
                case .pause:
                    self.isWorkoutPaused = true
                    self.sessionManager.pauseWorkout()
                    print("mirror pause")

                case .resume:
                    self.isWorkoutPaused = false
                    print("mirror resume")
                    self.sessionManager.resumeWorkout()

                case .stop:
                    DispatchQueue.main.async {
                            self.isWorkoutActive = false
                            self.isWorkoutPaused = false
                            print("📱 Mirror stop workout from watch")
                            self.sessionManager.stopWorkout()
                    }

                case .started:
                    if let raw = message["workoutType"] as? UInt,
                        let type = HKWorkoutActivityType(rawValue: raw)
                    {
                        print(
                            "📱 Mirror start workout from watch: \(type.displayName)"
                        )
                        self.isWorkoutActive = true
                        self.isWorkoutPaused = false
                        self.sessionManager.startWorkout(of: type)

                    }
                }
            } else if message["cmd"] as? String == "updateMetrics" {
                if let hr = message["heartRate"] as? Double,
                    let energy = message["energy"] as? Double,
                    let dist = message["distance"] as? Double,
                    let time = message["time"] as? Double
                {
                    self.heartRate = hr
                    self.energyBurned = energy
                    self.distance = dist
                    self.timeActive = time
                    print(
                        "📈 Updated metrics from Watch: HR=\(hr), kcal=\(energy), dist=\(dist), time=\(time)"
                    )
                }
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
        if session.isReachable {
            sendMessage(["cmd": "pause"])  // relay to watch (owner)
        } else {
            sessionManager.pauseWorkout()
        }
    }

    func resumeWorkoutFromPhone() {
        if session.isReachable {
            sendMessage(["cmd": "resume"])  // relay to watch (owner)
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

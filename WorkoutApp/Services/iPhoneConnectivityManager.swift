//
//  iPhoneConnectivityManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 16/10/25.
//

import Foundation
import WatchConnectivity
import HealthKit

@Observable
final class iPhoneConnectivityManager: NSObject {
    private let sessionManager = WorkoutSessionManager()
    static let shared = iPhoneConnectivityManager()
    
    private let session = WCSession.default
    var isWorkoutActive = false
    var isWorkoutPaused = false
    
    override init() {
        super.init( )
        guard WCSession.isSupported() else {
            return
        }
        
        session.delegate = self
        session.activate()
        
    }
    
}

extension iPhoneConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
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
    
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        print("iphone received: \(message)")

        // ✅ Always reply, even if empty, to avoid WCErrorCodeDeliveryFailed
       // defer { replyHandler(["status": "ok"]) }
        self.handleIncomingMessage(message)
    }

    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        DispatchQueue.main.async {
            print("📬 Received background message: \(userInfo)")
            self.handleIncomingMessage(userInfo)
        }
    }
    
}

private extension iPhoneConnectivityManager {
    func handleIncomingMessage(_ message: [String: Any]) {
        DispatchQueue.main.async {
            if let cmdRaw = message["cmd"] as? String,
               let cmd = WorkoutCommand(rawValue: cmdRaw) {
                switch cmd {
                case .start:
                    if let typeRaw = message["workoutType"] as? UInt,
                       let type = HKWorkoutActivityType(rawValue: typeRaw) {
                        
                        print("ini is workout active:\(self.isWorkoutActive)")
                        self.isWorkoutActive = true
                        print("ini is workout active:\(self.isWorkoutActive)")
                        self.isWorkoutPaused = false
                        
                        if !self.sessionManager.isRunning {
                            self.sessionManager.startWorkout(of: type)
                        } else {
                            print("ℹ️ iPhone workout already running; ignoring duplicate start")
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
                    self.isWorkoutActive = false
                    self.isWorkoutPaused = false
                    print("📱 Mirror stop workout from watch")
                    self.sessionManager.stopWorkout()
                case .started:
                    if let raw = message["workoutType"] as? UInt,
                       let type = HKWorkoutActivityType(rawValue: raw) {
                        print("📱 Mirror start workout from watch: \(type.displayName)")
                        self.isWorkoutActive = true
                        self.isWorkoutPaused = false
                        self.sessionManager.startWorkout(of: type)
                    }
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
            session.transferUserInfo(data) // ✅ fallback
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
            print("❌ Failed to send workout type: \(error.localizedDescription)")
        }
        print("📤 Sent selected workout: \(String(describing: type))")
    }
    
    func startWorkoutFromPhone(type: HKWorkoutActivityType) {
        // If reachable -> watch owns session
        if session.isReachable {
            sendMessage(["cmd": "start", "workoutType": type.rawValue])
        } else {
            // no watch -> phone owns workout
            sessionManager.startWorkout(of: type)
            print("📱 Phone started workout locally (no watch reachable)")
        }
    }
    
    func pauseWorkoutFromPhone() {
        if session.isReachable {
            sendMessage(["cmd": "pause"]) // relay to watch (owner)
        } else {
            sessionManager.pauseWorkout()
        }
    }

    func resumeWorkoutFromPhone() {
        if session.isReachable {
            sendMessage(["cmd": "resume"]) // relay to watch (owner)
        } else {
            sessionManager.resumeWorkout()
        }
    }

    func stopWorkoutFromPhone() {
        if session.isReachable {
            sendMessage(["cmd": "stop"]) // relay to watch (owner)
        } else {
            sessionManager.stopWorkout()
        }
    }
}


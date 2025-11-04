//
//  iPhoneConnectivityManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 16/10/25.
//

import Foundation
import WatchConnectivity
import HealthKit

final class iPhoneConnectivityManager: NSObject, ObservableObject {
    private let workoutManager = WorkoutSessionManager()
    static let shared = iPhoneConnectivityManager()
    private let session = WCSession.default
    
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
        
        if activationState == .activated {
            sendMessage(["phoneReady": true])
            print("ℹ️ Phone is ready to receive data.")
        }
        print("iPhone WCSession activated: \(activationState.rawValue)")
        
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print("iphone received: \(message)")
            
            if let cmdRaw = message["cmd"] as? String,
               let cmd = WorkoutCommand(rawValue: cmdRaw) {
                
                switch cmd {
                case .start:
                    if let typeRaw = message["workoutType"] as? UInt,
                       let type = HKWorkoutActivityType(rawValue: typeRaw) {
                        self.workoutManager.startWorkout(of: type)
                    }

                case .pause:
                    self.workoutManager.pauseWorkout()

                case .resume:
                    self.workoutManager.resumeWorkout()

                case .stop:
                    self.workoutManager.stopWorkout()
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
}

//
//  WatchConnectivityManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 15/10/25.
//

import WatchConnectivity
import Foundation
import Combine
import HealthKit

enum WorkoutCategory: String {
    case cardio
    case strength
}

@Observable
class WatchConnectivityManager: NSObject {
    static let shared = WatchConnectivityManager()
    private let workoutManager = WorkoutSessionManager()

    private let session = WCSession.default
    var selectedWorkoutType: HKWorkoutActivityType? = nil
    
    var phoneReady = false
    var shouldStartWorkout = false
    var isReachable: Bool = false

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
        session.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("📩 Received message: \(message)")
    DispatchQueue.main.async {
            if let typeWorkout = message["selectedWorkout"] as? UInt,
               let type = HKWorkoutActivityType(rawValue: typeWorkout) {
                self.selectedWorkoutType = type
                print("✅ Updated selectedWorkoutType: \(type.displayName)")
                
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
    
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
                    self.isReachable = session.isReachable
                    if self.isReachable {
                        //self.requestTodayWorkout()
                    }
                }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            if self.isReachable {
                //self.requestTodayWorkout()
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


//
//  WatchConnectivityManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 15/10/25.
//

import WatchConnectivity
import Foundation
import Combine

enum WorkoutCategory: String {
    case cardio
    case strength
}

@Observable
class WatchConnectivityManager: NSObject {
    static let shared = WatchConnectivityManager()

    private let session = WCSession.default
    var todayCategory: WorkoutCategory? = nil
    
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
    
    func requestTodayWorkout() {
            guard session.isReachable else {
                isReachable = false
                return
            }
            
            let message = ["request": "todayWorkout"]
            WCSession.default.sendMessage(message, replyHandler: { reply in
                if let category = reply["category"] as? String {
                    DispatchQueue.main.async {
                        self.todayCategory = WorkoutCategory(rawValue: category)
                    }
                }
            }, errorHandler: { error in
                print("Error requesting workout: \(error)")
            })
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
                        self.requestTodayWorkout()
                    }
                }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            if self.isReachable {
                self.requestTodayWorkout()
            }
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message: \(message)")
        
        DispatchQueue.main.async {
            if message["phoneReady"] as? Bool == true {
                self.phoneReady = true
                print("Watch Ready")
            }
            
            if message["startWorkout"] as? Bool == true {
                self.shouldStartWorkout = true
                print("Start Workout")
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


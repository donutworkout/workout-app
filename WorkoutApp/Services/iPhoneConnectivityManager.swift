//
//  iPhoneConnectivityManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 16/10/25.
//

import Foundation
import WatchConnectivity

final class iPhoneConnectivityManager: NSObject, ObservableObject {
    static let shared = iPhoneConnectivityManager()
    private let session = WCSession.default
    
    override init() {
        super.init( )
        guard WCSession.isSupported() else {
            print("WCSession is not supported")
            return
        }
        
        session.delegate = self
        session.activate()
        
    }
    
}

extension iPhoneConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        print("iPhone WCSession activated: \(activationState.rawValue)")
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("iphone received: \(message)")
    }
    
}

extension iPhoneConnectivityManager {
    func sendMessage(_ data: [String: Any]) {
        guard session.activationState == .activated else {
            print("⚠️ WCSession belum aktif — tunggu dulu sebelum kirim pesan.")
            return
        }
        guard session.isReachable else {
            print("⚠️ Session belum reachable (cek Watch app terbuka & terhubung).")
            return
        }

        session.sendMessage(data, replyHandler: nil) { error in
            print("❌ Error sending message: \(error.localizedDescription)")
        }
    }
}

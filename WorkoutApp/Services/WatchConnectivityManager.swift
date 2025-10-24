//
//  WatchConnectivityManager.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 15/10/25.
//

import WatchConnectivity
import Foundation

final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    private let session = WCSession.default

    override private init() {
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
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message: \(message)")
    }

#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
#endif

    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Reachability changed: \(session.isReachable)")
    }
}

// MARK: - Message Sending

extension WatchConnectivityManager {
        func sendMessage(_ data: [String: Any]) {
            // Pastikan WCSession sudah aktif
            guard session.activationState == .activated else {
                print("WCSession belum aktif — tunggu dulu sebelum kirim pesan.")
                return
            }

            // Pastikan perangkat lain reachable
            guard session.isReachable else {
                print("Session belum reachable (cek Watch app terbuka & terhubung).")
                return
            }

            // Kirim pesan
            session.sendMessage(data, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        }
}

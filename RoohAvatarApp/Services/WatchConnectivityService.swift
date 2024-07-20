//
//  WatchConnectivityService.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 20/07/2024.
//

import Foundation
import WatchConnectivity

protocol WatchConnectivityServiceProtocol {
    func setupWCSession() -> Bool
    func sendMessageToWatch(data: [String: Any]) async throws
}

class WatchConnectivityService: NSObject {
    var session: WCSession!
}

extension WatchConnectivityService: WatchConnectivityServiceProtocol {
    func setupWCSession() -> Bool {
        
        guard WCSession.isSupported() else {
            return false
        }
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
        return true
        
    }
    
    func sendMessageToWatch(data: [String: Any]) async throws {
        await withCheckedContinuation { continuation in
            session?.sendMessage(data, replyHandler: { reply in
                continuation.resume(returning: reply)
            }, errorHandler: { error in
                continuation.resume(throwing: error as! Never)
//                print("Error sending message: \(error)")
            })
        }
    }
}


extension WatchConnectivityService: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print(#function)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("Session activated")
        self.session = session
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        // Handle received message from watchOS
    }
}

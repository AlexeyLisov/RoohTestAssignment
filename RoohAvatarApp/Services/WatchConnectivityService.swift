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
    func activateSession() async
    func sendMessageToWatch(data: [String: Any]) async throws
}

class WatchConnectivityService: NSObject {
    var session: WCSession!
    
    private var continuation: CheckedContinuation<Void, Never>?
}

extension WatchConnectivityService: WatchConnectivityServiceProtocol {
    func setupWCSession() -> Bool {
        
        guard WCSession.isSupported() else {
            return false
        }
        
        guard session == nil else {
            return true // already created
        }
        
        session = WCSession.default
        session?.delegate = self
        
        return true
        
    }
    
    func activateSession() async {
        
        guard let session = session,
              session.activationState != .activated else {
            return
        }
        
        session.activate()
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            self.continuation = continuation
        }
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
        self.continuation?.resume(returning: ())
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        // Handle received message from watchOS
    }
}

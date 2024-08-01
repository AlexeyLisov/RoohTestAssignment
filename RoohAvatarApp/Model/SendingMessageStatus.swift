//
//  SendingMessageStatus.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 01/08/2024.
//

import WatchConnectivity


enum SendingMessageStatus {
    case notRequested
    case creatingSession
    case sendingMessage
    case error(WCError)
    case success
}

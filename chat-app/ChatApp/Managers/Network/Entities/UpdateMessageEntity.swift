//
//  UpdateMessageEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/26/24.
//

import Foundation

class UpdateMessageEntity: RequestableApiEntity {
    typealias ResponseEntity = SendMessageRespondableEntity

    static var method: BaseNetworkOperation.Method { .put }

    var path: String { "messages" }
    var isIgnoreAccessTokenError: Bool { ignoreError }
    var isIgnoreLogoutErrors: Bool { ignoreError }
    var body: RequestBody? {
        UpdateMessageBody(deviceId: deviceId, message: message, messageId: messageId)
    }
    private var ignoreError: Bool { false }
    private let deviceId: String
    private let message: String
    private let messageId: Int

    init(deviceId: String, message: String, messageId: Int) {
        self.deviceId = deviceId
        self.message = message
        self.messageId = messageId
    }
}

struct UpdateMessageBody : RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    let deviceId: String
    let message: String
    let messageId: Int
}

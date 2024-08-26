//
//  DeleteMessageEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/26/24.
//

import Foundation

class DeleteMessageEntity: RequestableApiEntity {
    typealias ResponseEntity = SendMessageRespondableEntity

    static var method: BaseNetworkOperation.Method { .delete }

    var path: String { "messages" }
    var isIgnoreAccessTokenError: Bool { ignoreError }
    var isIgnoreLogoutErrors: Bool { ignoreError }
    var body: RequestBody? {
        DeleteMessageBody(deviceId: deviceId, messageId: messageId)
    }
    private var ignoreError: Bool { false }
    private let deviceId: String
    private let messageId: Int

    init(deviceId: String, messageId: Int) {
        self.deviceId = deviceId
        self.messageId = messageId
    }
}

struct DeleteMessageBody : RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    let deviceId: String
    let messageId: Int
}

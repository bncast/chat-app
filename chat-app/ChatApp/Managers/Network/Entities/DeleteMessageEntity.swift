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
        DeleteMessageBody(messageId: messageId)
    }
    private var ignoreError: Bool { false }
    private let messageId: Int

    init(messageId: Int) {
        self.messageId = messageId
    }
}

struct DeleteMessageBody : RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    let messageId: Int
}

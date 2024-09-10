//
//  SendMessageEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/20/24.
//

import Foundation
class SendMessageEntity: RequestableApiEntity {
    typealias ResponseEntity = SendMessageRespondableEntity

    static var method: BaseNetworkOperation.Method { .post }

    var path: String { "send" }
    var isIgnoreAccessTokenError: Bool { ignoreError }
    var isIgnoreLogoutErrors: Bool { ignoreError }
    var body: RequestBody? {
        SendMessageBody(message: message, roomUserId: roomUserId, replyToId: replyToId)
    }
    private var ignoreError: Bool { false }
    private let message: String
    private let roomUserId: Int
    private let replyToId: Int?

    init(message: String, roomUserId: Int, replyToId: Int?) {
        self.message = message
        self.roomUserId = roomUserId
        self.replyToId = replyToId
    }
}

struct SendMessageBody : RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    let message: String
    let roomUserId: Int
    let replyToId: Int?
}

struct SendMessageRespondableEntity: RespondableApiEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var success: Int
    var error: ErrorMessage?
}

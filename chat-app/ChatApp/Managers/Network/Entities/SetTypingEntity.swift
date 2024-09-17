//
//  SetTypingEntity.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 9/16/24.
//

import Foundation

class SetTypingEntity: RequestableApiEntity {
    typealias ResponseEntity = SetTypingRespondableEntity

    static var method: BaseNetworkOperation.Method { .post }

    var path: String { "messages/typing" }
    var isIgnoreAccessTokenError: Bool { ignoreError }
    var isIgnoreLogoutErrors: Bool { ignoreError }
    var body: RequestBody? {
        SetTypingBody(roomUserId: roomUserId, isTyping: isTyping)
    }

    private var ignoreError: Bool { true }
    let roomUserId: Int
    let isTyping: Bool

    init(roomUserId: Int, isTyping: Bool) {
        self.roomUserId = roomUserId
        self.isTyping = isTyping
    }
}

struct SetTypingBody : RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    let roomUserId: Int
    let isTyping: Bool
}

struct SetTypingRespondableEntity: RespondableApiEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var success: Int
    var error: ErrorMessage?
}

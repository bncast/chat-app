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
    var body: RequestBody? { SendMessageBody(message: message, sender: sender) }
    private var ignoreError: Bool { false }
    private let message: String
    private let sender: String

    init(message: String, sender: String) {
        self.message = message
        self.sender = sender
    }
}

struct SendMessageBody : RequestUrlEncodedBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }
    
    var message: String
    var sender: String
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

//
//  JoinChatRoomEntity.swift
//  ChatApp
//
//  Created by William Rena on 8/21/24.
//

import Foundation

class JoinChatRoomEntity: RequestableApiEntity {
    typealias ResponseEntity = JoinChatRoomRespondableEntity

    static var method: BaseNetworkOperation.Method { .post }
    var path: String { "rooms/join" }
    var body: RequestBody? { JoinChatRoomRequestBody(roomId: roomId, password: password) }

    private let roomId: Int
    private let password: String?

    init(roomId: Int, password: String?) {
        self.roomId = roomId
        self.password = password
    }
}

// MARK: - Defining body
struct JoinChatRoomRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var roomId: Int
    var password: String?
}

// MARK: Defining response
struct JoinChatRoomRespondableEntity: RespondableApiEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var success: Int
    var error: ErrorMessage?
    var chatRoom: ChatRoomEntity?
}

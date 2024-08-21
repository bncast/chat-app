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
    var body: RequestBody? { JoinChatRoomRequestBody(roomId: roomId, deviceId: deviceId, password: password) }

    private let roomId: Int
    private let deviceId: String
    private let password: String?

    init(roomId: Int, deviceId: String, password: String?) {
        self.roomId = roomId
        self.deviceId = deviceId
        self.password = password
    }
}

// MARK: - Defining body
struct JoinChatRoomRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var roomId: Int
    var deviceId: String
    var password: String?
}

// MARK: Defining response
struct JoinChatRoomRespondableEntity: RespondableApiEntity {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var success: Int
    var error: ErrorMessage?
    var chatroom: ChatRoomEntity?
}

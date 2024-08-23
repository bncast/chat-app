//
//  RemoveMemberFromChatRoomEntity.swift
//  ChatApp
//
//  Created by William Rena on 8/23/24.
//

import Foundation

class RemoveMemberFromChatRoomEntity: RequestableApiEntity {
    typealias ResponseEntity = RemoveMemberFromChatRoomRespondableEntity

    static var method: BaseNetworkOperation.Method { .delete }
    var path: String { "rooms/users" }
    var body: RequestBody? { RemoveMemberFromChatRoomRequestBody(roomUserId: roomUserId, deviceId: deviceId) }

    private let roomUserId: Int
    private let deviceId: String

    init(roomUserId: Int, deviceId: String) {
        self.roomUserId = roomUserId
        self.deviceId = deviceId
    }
}

// MARK: - Defining body
struct RemoveMemberFromChatRoomRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var roomUserId: Int
    var deviceId: String
}

// MARK: Defining response
struct RemoveMemberFromChatRoomRespondableEntity: RespondableApiEntity {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var success: Int
    var error: ErrorMessage?
}

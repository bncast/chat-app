//
//  RemoveFromChatRoomEntity.swift
//  ChatApp
//
//  Created by William Rena on 8/23/24.
//

import Foundation

class RemoveChatRoomEntity: RequestableApiEntity {
    typealias ResponseEntity = RemoveChatRoomRespondableEntity

    static var method: BaseNetworkOperation.Method { .delete }
    var path: String { "rooms" }
    var body: RequestBody? { RemoveChatRoomRequestBody(deviceId: deviceId, roomUserId: roomUserId) }

    private let deviceId: String
    private let roomUserId: Int

    init(deviceId: String, roomUserId: Int) {
        self.deviceId = deviceId
        self.roomUserId = roomUserId
    }
}

// MARK: - Defining body
struct RemoveChatRoomRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var deviceId: String
    var roomUserId: Int
}

// MARK: Defining response
struct RemoveChatRoomRespondableEntity: RespondableApiEntity {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var success: Int
    var error: ErrorMessage?
}

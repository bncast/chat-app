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
    var body: RequestBody? { RemoveChatRoomRequestBody(roomUserId: roomUserId) }

    private let roomUserId: Int

    init(roomUserId: Int) {
        self.roomUserId = roomUserId
    }
}

// MARK: - Defining body
struct RemoveChatRoomRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var roomUserId: Int
}

// MARK: Defining response
struct RemoveChatRoomRespondableEntity: RespondableApiEntity {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var success: Int
    var error: ErrorMessage?
}

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
    var path: String { "rooms/detail" }
    var body: RequestBody? { RemoveMemberFromChatRoomRequestBody(roomUserId: roomUserId) }

    private let roomUserId: Int

    init(roomUserId: Int) {
        self.roomUserId = roomUserId
    }
}

// MARK: - Defining body
struct RemoveMemberFromChatRoomRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var roomUserId: Int
}

// MARK: Defining response
struct RemoveMemberFromChatRoomRespondableEntity: RespondableApiEntity {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var success: Int
    var error: ErrorMessage?
}

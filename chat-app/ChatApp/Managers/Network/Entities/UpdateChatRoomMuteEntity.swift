//
//  UpdateChatRoomMuteEntity.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 9/16/24.
//

import Foundation

class UpdateChatRoomMuteEntity: RequestableApiEntity {
    typealias ResponseEntity = UpdateChatRoomMuteRespondableEntity

    static var method: BaseNetworkOperation.Method { .put }
    var path: String { "rooms/mute" }
    var body: RequestBody? { UpdateChatRoomMuteRequestBody(roomUserId: roomUserId) }

    private let roomUserId: Int

    init(roomUserId: Int) {
        self.roomUserId = roomUserId
    }
}

// MARK: - Defining body
struct UpdateChatRoomMuteRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var roomUserId: Int
}

// MARK: Defining response
struct UpdateChatRoomMuteRespondableEntity: RespondableApiEntity {
    var success: Int
    var error: ErrorMessage?
}


//
//  UpdateChatRoomNameEntity.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/21/24.
//

import Foundation

class UpdateChatRoomNameEntity: RequestableApiEntity {
    typealias ResponseEntity = UpdateChatRoomNameRespondableEntity

    static var method: BaseNetworkOperation.Method { .put }
    var path: String { "rooms" }
    var body: RequestBody? { UpdateChatRoomNameRequestBody(name: name, deviceId: deviceId, roomUserId: roomUserId) }

    private let name: String
    private let deviceId: String
    private let roomUserId: Int

    init(name: String, roomUserId: Int) {
        self.name = name
        self.deviceId = AppConstant.shared.deviceId ?? ""
        self.roomUserId = roomUserId
    }
}

// MARK: - Defining body
struct UpdateChatRoomNameRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var name: String
    var deviceId: String
    var roomUserId: Int
}

// MARK: Defining response
struct UpdateChatRoomNameRespondableEntity: RespondableApiEntity {
    var success: Int
    var error: ErrorMessage?
    var chatrooms: ChatRoomEntity
}

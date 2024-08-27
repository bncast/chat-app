//
//  AcceptInvitationEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/27/24.
//

import Foundation
class AcceptInvitationEntity: RequestableApiEntity {
    typealias ResponseEntity = JoinChatRoomRespondableEntity

    static var method: BaseNetworkOperation.Method { .post }

    var path: String { "invites/accept" }
    var isIgnoreAccessTokenError: Bool { ignoreError }
    var isIgnoreLogoutErrors: Bool { ignoreError }
    var body: RequestBody? {
        AcceptInvitationBody(deviceId: deviceId, roomId: roomId)
    }
    private var ignoreError: Bool { false }
    private let deviceId: String
    private let roomId: Int

    init(deviceId: String, roomId: Int) {
        self.deviceId = deviceId
        self.roomId = roomId
    }
}

struct AcceptInvitationBody : RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    let deviceId: String
    let roomId: Int
}

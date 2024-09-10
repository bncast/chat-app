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
        AcceptInvitationBody(invitationId: invitationId, roomId: roomId)
    }
    private var ignoreError: Bool { false }
    private let invitationId: Int
    private let roomId: Int

    init(invitationId: Int, roomId: Int) {
        self.invitationId = invitationId
        self.roomId = roomId
    }
}

struct AcceptInvitationBody : RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    let invitationId: Int
    let roomId: Int
}

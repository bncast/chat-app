//
//  SendInvitationEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/26/24.
//

import Foundation
class SendInvitationEntity: RequestableApiEntity {
    typealias ResponseEntity = SendInvitationRespondableEntity

    static var method: BaseNetworkOperation.Method { .post }

    var path: String { "invites" }
    var isIgnoreAccessTokenError: Bool { ignoreError }
    var isIgnoreLogoutErrors: Bool { ignoreError }
    var body: RequestBody? {
        SendInvitationBody(deviceId: deviceId, inviteeDeviceId: inviteeDeviceId, roomId: roomId)
    }
    private var ignoreError: Bool { false }
    private let deviceId: String
    private let inviteeDeviceId: String
    private let roomId: Int

    init(deviceId: String, inviteeDeviceId: String, roomId: Int) {
        self.deviceId = deviceId
        self.inviteeDeviceId = inviteeDeviceId
        self.roomId = roomId
    }
}

struct SendInvitationBody : RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    let deviceId: String
    let inviteeDeviceId: String
    let roomId: Int
}

struct SendInvitationRespondableEntity: RespondableApiEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var success: Int
    var error: ErrorMessage?
}


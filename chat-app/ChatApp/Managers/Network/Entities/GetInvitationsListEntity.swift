//
//  GetInvitationsListEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/26/24.
//

import Foundation

class GetInvitationsListEntity: RequestableApiEntity {
    typealias ResponseEntity = DeleteRoomUserRespondableEntity

    static var method: BaseNetworkOperation.Method { .get }
    var path: String { "invites?device_id=\(AppConstant.shared.deviceId ?? "")" }

    private let deviceId: String

    init(roomUserId: Int) {
        self.deviceId = AppConstant.shared.deviceId ?? ""
    }
}

// MARK: Defining response
struct GetInvitationsListRespondableEntity: RespondableApiEntity {
    var invitations: [InvitationEntity]
    var success: Int
    var error: ErrorMessage?
}

struct InvitationEntity: Codable {
    let chatName: String
    let chatImageUrl: String
    let inviterName: String
    let roomId: Int
}

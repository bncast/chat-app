//
//  GetInvitationsListEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/26/24.
//

import Foundation

class GetInvitationsListEntity: RequestableApiEntity {
    typealias ResponseEntity = GetInvitationsListRespondableEntity

    static var method: BaseNetworkOperation.Method { .get }
    var path: String { "invites" }
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
    let invitationId: Int
}

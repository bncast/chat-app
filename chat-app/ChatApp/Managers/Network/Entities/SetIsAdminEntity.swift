//
//  SetIsAdminEntity.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/22/24.
//

import Foundation

class SetIsAdminEntity: RequestableApiEntity {
    typealias ResponseEntity = SetIsAdminRespondableEntity

    static var method: BaseNetworkOperation.Method { .patch }
    var path: String { "rooms/detail" }
    var body: RequestBody? { SetIsAdminRequestBody(isAdmin: isAdmin, roomUserId: roomUserId) }

    private let isAdmin: Bool
    private let roomUserId: Int

    init(isAdmin: Bool, roomUserId: Int) {
        self.isAdmin = isAdmin
        self.roomUserId = roomUserId
    }
}

// MARK: - Defining body
struct SetIsAdminRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var isAdmin: Bool
    var roomUserId: Int
}

// MARK: Defining response
struct SetIsAdminRespondableEntity: RespondableApiEntity {
    var success: Int
    var error: ErrorMessage?
}

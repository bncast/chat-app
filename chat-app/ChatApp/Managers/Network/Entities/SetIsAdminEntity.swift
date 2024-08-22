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
    var body: RequestBody? { SetIsAdminRequestBody(isAdmin: isAdmin, deviceId: deviceId, roomUserId: roomUserId) }

    private let isAdmin: Bool
    private let deviceId: String
    private let roomUserId: Int

    init(isAdmin: Bool, roomUserId: Int) {
        self.isAdmin = isAdmin
        self.deviceId = AppConstant.shared.deviceId ?? ""
        self.roomUserId = roomUserId
    }
}

// MARK: - Defining body
struct SetIsAdminRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var isAdmin: Bool
    var deviceId: String
    var roomUserId: Int
}

// MARK: Defining response
struct SetIsAdminRespondableEntity: RespondableApiEntity {
    var success: Int
    var error: ErrorMessage?
}

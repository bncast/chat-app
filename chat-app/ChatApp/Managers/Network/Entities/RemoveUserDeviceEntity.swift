//
//  RemoveUserDeviceEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/12/24.
//

import Foundation

class RemoveUserDeviceEntity: RequestableApiEntity {
    typealias ResponseEntity = RemoveChatRoomRespondableEntity

    static var method: BaseNetworkOperation.Method { .delete }
    var path: String { "devices" }
    var body: RequestBody? { RemoveUserDeviceRequestBody(userDeviceId: userDeviceId) }

    private let userDeviceId: Int

    init(userDeviceId: Int) {
        self.userDeviceId = userDeviceId
    }
}

// MARK: - Defining body
struct RemoveUserDeviceRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var userDeviceId: Int
}

// MARK: Defining response
struct RemoveUserDeviceRespondableEntity: RespondableApiEntity {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var success: Int
    var error: ErrorMessage?
}

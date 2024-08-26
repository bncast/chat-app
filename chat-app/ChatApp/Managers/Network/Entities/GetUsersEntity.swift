//
//  GetUsersEntity.swift
//  ChatApp
//
//  Created by William Rena on 8/26/24.
//

import Foundation

class GetUsersEntity: RequestableApiEntity {
    typealias ResponseEntity = GetUsersRespondableEntity

    static var method: BaseNetworkOperation.Method { .get }
    var path: String { "users?device_id=\(deviceId)&room_id=\(roomId)" }

    var deviceId: String
    var roomId: Int

    init(roomId: Int) {
        guard let deviceId = AppConstant.shared.deviceId else { fatalError() }

        self.deviceId = deviceId
        self.roomId = roomId
    }
}

// MARK: Defining response
struct GetUsersRespondableEntity: RespondableApiEntity {
    var success: Int
    var error: ErrorMessage?
    var users: [UserListEntity]
}

struct UserListEntity: Codable {
    var name: String
    var deviceId: String
    var userImageUrl: String
}

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
    var path: String { "users" }

    var deviceId: String

    init(deviceId: String) {
        self.deviceId = deviceId
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

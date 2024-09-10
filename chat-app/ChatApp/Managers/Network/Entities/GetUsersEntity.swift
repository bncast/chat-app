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
    var path: String { "users?room_id=\(roomId)" }

    var roomId: Int

    init(roomId: Int) {
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
    var userId: Int
    var userImageUrl: String
}

//
//  CreateChatRoomEntity.swift
//  ChatApp
//
//  Created by William Rena on 8/22/24.
//

import Foundation

class CreateChatRoomEntity: RequestableApiEntity {
    typealias ResponseEntity = CreateChatRoomRespondableEntity

    static var method: BaseNetworkOperation.Method { .post }
    var path: String { "rooms" }
    var body: RequestBody? { CreateChatRoomRequestBody(name: name, deviceId: deviceId, password: password) }

    private let name: String
    private let deviceId: String
    private let password: String?

    init(name: String, deviceId: String, password: String?) {
        self.name = name
        self.deviceId = deviceId
        self.password = password
    }
}

// MARK: - Defining body
struct CreateChatRoomRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var name: String
    var deviceId: String
    var password: String?
}

// MARK: Defining response
struct CreateChatRoomRespondableEntity: RespondableApiEntity {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var success: Int
    var error: ErrorMessage?
    var chatroom: ChatRoomEntity?
}

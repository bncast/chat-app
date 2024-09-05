//
//  GetMessageEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/20/24.
//

import Foundation
class GetMessageEntity: RequestableApiEntity {
    typealias ResponseEntity = GetMessageRespondableEntity

    static var method: BaseNetworkOperation.Method { .get }

    var path: String { "listen?device_id=\(deviceId)&room_id=\(roomId)" }
    var isIgnoreAccessTokenError: Bool { ignoreError }
    var isIgnoreLogoutErrors: Bool { ignoreError }
    private var ignoreError: Bool { false }

    var deviceId: String
    var roomId: Int

    init(deviceId: String, roomId: Int) {
        self.deviceId = deviceId
        self.roomId = roomId
    }
}

struct GetMessageRespondableEntity: RespondableApiEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let formatter = Date.utcDateFormatter
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        decoder.dateDecodingStrategy = .formatted(formatter)

        return decoder
    }

    var success: Int
    var error: ErrorMessage?
}

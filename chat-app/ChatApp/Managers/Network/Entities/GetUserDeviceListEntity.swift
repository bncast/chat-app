//
//  GetUserDeviceEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/12/24.
//

import Foundation

class GetUserDeviceListEntity: RequestableApiEntity {
    typealias ResponseEntity = GetUserDeviceListRespondableEntity

    static var method: BaseNetworkOperation.Method { .get }
    var path: String { "devices" }
}


// MARK: Defining response
struct GetUserDeviceListRespondableEntity: RespondableApiEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var success: Int
    var error: ErrorMessage?
    var devices: [UserDeviceEntity]
}

struct UserDeviceEntity: Codable {
    var id: Int
    var deviceId: String
    var deviceName: String
}

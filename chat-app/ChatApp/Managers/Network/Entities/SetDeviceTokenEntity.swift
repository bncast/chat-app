//
//  SetDeviceTokenEntity.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 9/5/24.
//

import Foundation

class SetDeviceTokenEntity: RequestableApiEntity {
    typealias ResponseEntity = SetDeviceTokenRespondableEntity

    static var method: BaseNetworkOperation.Method { .post }
    var path: String { "notification" }
    var body: RequestBody? {
        SetDeviceTokenRequestBody(deviceId: deviceId, deviceToken: deviceToken)
    }

    private let deviceId: String
    private let deviceToken: String

    init(deviceId: String, deviceToken: String) {
        self.deviceId = deviceId
        self.deviceToken = deviceToken
    }
}

// MARK: - Defining body
struct SetDeviceTokenRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var deviceId: String
    var deviceToken: String
}

struct SetDeviceTokenRespondableEntity: RespondableApiEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var success: Int
    var error: ErrorMessage?
}

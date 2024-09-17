//
//  LogoutUserEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/11/24.
//

import Foundation

class LogoutUserEntity: RequestableApiEntity {
    typealias ResponseEntity = LogoutUserRespondableEntity

    static var method: BaseNetworkOperation.Method { .post }

    var path: String { "logout" }
    var isIgnoreAccessTokenError: Bool { ignoreError }
    var isIgnoreLogoutErrors: Bool { ignoreError }
    var body: RequestBody? { LogoutUserBody(deviceId: deviceId) }
    private var ignoreError: Bool { false }

    var deviceId: String = AppConstant.shared.deviceId ?? ""
}

struct LogoutUserBody : RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    let deviceId: String
}

struct LogoutUserRespondableEntity: RespondableApiEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var success: Int
    var error: ErrorMessage?
}

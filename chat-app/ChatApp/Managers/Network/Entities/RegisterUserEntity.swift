//
//  RegisterUserEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/9/24.
//

import Foundation

class RegisterUserEntity: RequestableApiEntity {
    typealias ResponseEntity = LoginUserRespondableEntity

    static var method: BaseNetworkOperation.Method { .post }

    var path: String { "register" }
    var isIgnoreAccessTokenError: Bool { ignoreError }
    var isIgnoreLogoutErrors: Bool { ignoreError }
    var body: RequestBody? {
        RegisterUserBody(displayName: displayName, username: username, password: password, deviceId: deviceId)
    }
    private var ignoreError: Bool { false }
    private let displayName: String
    private let username: String
    private let password: String
    private let deviceId: String


    init(displayName: String, username: String, password: String) {
        self.displayName = displayName
        self.username = username
        self.password = password
        self.deviceId = AppConstant.shared.getDeviceId()
    }
}

struct RegisterUserBody : RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    let displayName: String
    let username: String
    let password: String
    let deviceId: String
}

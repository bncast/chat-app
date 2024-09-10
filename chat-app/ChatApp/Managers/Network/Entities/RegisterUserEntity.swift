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
        RegisterUserBody(displayName: displayName, username: username, password: password)
    }
    private var ignoreError: Bool { false }
    private let displayName: String
    private let username: String
    private let password: String


    init(displayName: String, username: String, password: String) {
        self.displayName = displayName
        self.username = username
        self.password = password
    }
}

struct RegisterUserBody : RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    let displayName: String
    let username: String
    let password: String
}

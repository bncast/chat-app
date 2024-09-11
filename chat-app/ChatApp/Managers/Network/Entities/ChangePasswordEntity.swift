//
//  ChangePasswordEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/11/24.
//

import Foundation

class ChangePasswordEntity: RequestableApiEntity {
    typealias ResponseEntity = ChangePasswordRespondableEntity

    static var method: BaseNetworkOperation.Method { .post }
    var path: String { "users/password" }
    var body: RequestBody? {
        ChangePasswordRequestBody(oldPassword: oldPassword, newPassword: newPassword)
    }

    private let oldPassword: String
    private let newPassword: String

    init(oldPassword: String, newPassword:String) {
        self.oldPassword = oldPassword
        self.newPassword = newPassword
    }
}

// MARK: - Defining body
struct ChangePasswordRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var oldPassword: String
    var newPassword: String
}

// MARK: Defining response
struct ChangePasswordRespondableEntity: RespondableApiEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var success: Int
    var error: ErrorMessage?
}

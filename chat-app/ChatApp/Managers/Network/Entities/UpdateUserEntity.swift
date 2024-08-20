//
//  UpdateUserEntity.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/20/24.
//

import KeychainAccess
import Foundation

class UpdateUserEntity: RequestableApiEntity {
    typealias ResponseEntity = UpdateUserRespondableEntity

    static var method: BaseNetworkOperation.Method { AppConstant.shared.forRegister ? .post : .put }
    var path: String { "users" }
    var body: RequestBody? { UpdateUserRequestBody(name: name, deviceId: deviceId) }

    private let name: String
    private let deviceId: String

    init(name: String) {
        self.name = name

        guard AppConstant.shared.isNewUser else {
            self.deviceId = AppConstant.shared.deviceId ?? ""
            return
        }

        let key = (0..<20).map { _ in
            guard let randomElement = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()
            else { return "" }
            return "\(randomElement)"
        }.joined()
        self.deviceId = key
        AppConstant.shared.forRegister = true
        AppConstant.shared.deviceId = key
    }
}

// MARK: - Defining body
struct UpdateUserRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var name: String
    var deviceId: String
}

// MARK: Defining response
struct UpdateUserRespondableEntity: RespondableApiEntity {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var success: Int
    var error: ErrorMessage?
    var user: UserEntity
}

struct UserEntity: Codable {
    var userImageUrl: String
    var deviceId: String
}

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

    static var method: BaseNetworkOperation.Method { .post }
    var path: String { "users" }
    var body: RequestBody? { UpdateUserRequestBody(name: name) }

    private let name: String

    init(name: String) {
        self.name = name
    }
}

// MARK: - Defining body
struct UpdateUserRequestBody: RequestJsonBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }

    var name: String
}

// MARK: Defining response
struct UpdateUserRespondableEntity: RespondableApiEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var success: Int
    var error: ErrorMessage?
    var info: UserInfoEntity?
}

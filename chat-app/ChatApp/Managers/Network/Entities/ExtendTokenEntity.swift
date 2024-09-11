//
//  ExtendTokenEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/11/24.
//

import Foundation

class ExtendTokenEntity: RequestableApiEntity {
    typealias ResponseEntity = LoginUserRespondableEntity

    static var method: BaseNetworkOperation.Method { .post }

    var path: String { "token/extend" }
    var isIgnoreAccessTokenError: Bool { ignoreError }
    var isIgnoreLogoutErrors: Bool { ignoreError }

    private var ignoreError: Bool { false }
}

struct ExtendTokenRespondableEntity: RespondableApiEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var success: Int
    var error: ErrorMessage?
}


//
//  AppVersionEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/19/24.
//

import Foundation
class AppVersionEntity: RequestableApiEntity {
    typealias ResponseEntity = AppVersionRespondableEntity

    static var method: BaseNetworkOperation.Method { .get }

    var path: String { "version" }
    var isIgnoreAccessTokenError: Bool { ignoreError }
    var isIgnoreLogoutErrors: Bool { ignoreError }
    private var ignoreError: Bool { false }

}

struct AppVersionRespondableEntity: RespondableApiEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var success: Int
    var version: String
    var error: ErrorMessage?
}

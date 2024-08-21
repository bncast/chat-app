//
//  GetMessageEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/20/24.
//

import Foundation
class GetMessageEntity: RequestableApiEntity {
    typealias ResponseEntity = GetMessageRespondableEntity

    static var method: BaseNetworkOperation.Method { .get }

    var path: String { "listen" }
    var isIgnoreAccessTokenError: Bool { ignoreError }
    var isIgnoreLogoutErrors: Bool { ignoreError }
    private var ignoreError: Bool { false }

}

struct GetMessageRespondableEntity: RespondableApiEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var success: Int
    var error: ErrorMessage?
}

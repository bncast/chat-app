//
//  GetUpdatesEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/13/24.
//

import Foundation
class GetUpdatesEntity: RequestableApiEntity {
    typealias ResponseEntity = GetMessageRespondableEntity

    static var method: BaseNetworkOperation.Method { .get }

    var path: String { "updates" }
    var isIgnoreAccessTokenError: Bool { ignoreError }
    var isIgnoreLogoutErrors: Bool { ignoreError }
    private var ignoreError: Bool { false }

}

struct GetUpdatesRespondableEntity: RespondableApiEntity {
    var success: Int
    var error: ErrorMessage?
}

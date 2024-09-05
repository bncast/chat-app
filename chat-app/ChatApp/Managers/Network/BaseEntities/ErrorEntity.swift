//
//  ErrorEntity.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

public struct ErrorMessage: Codable, Hashable {
    var code: String
    var message: String
    var details: [[String: String]]?
}

public struct ErrorEntity: Codable, Hashable {
    public var success: Int
    public var error: ErrorMessage?
}

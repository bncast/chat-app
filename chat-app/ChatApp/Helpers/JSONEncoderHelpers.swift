//
//  JSONEncoderHelpers.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

extension JSONEncoder {
    static func snakeCaseEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}

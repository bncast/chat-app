//
//  DataHelpers.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

extension Data {
    var prettyPrintedJSON: String? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: self)
            let data: Data = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        } catch _ {
            return nil
        }
    }
}

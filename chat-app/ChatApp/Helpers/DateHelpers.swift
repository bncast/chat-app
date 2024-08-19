//
//  DateHelpers.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

extension Date {
    init?(iso8601 string: String) {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: string) else { return nil }
        self = date
    }

    var toIso8601: String {
        ISO8601DateFormatter().string(from: self)
    }
}

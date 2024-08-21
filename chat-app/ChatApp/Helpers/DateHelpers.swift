//
//  DateHelpers.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation
extension Calendar {
    static func getUTC() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? TimeZone.autoupdatingCurrent
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }
}

extension Date {
    init?(iso8601 string: String) {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: string) else { return nil }
        self = date
    }

    var toIso8601: String {
        ISO8601DateFormatter().string(from: self)
    }

    func toString(by format: String) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.calendar = calendar
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }

    static var utcDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar.getUTC()
        return formatter
    }

    func isSameDayWith(date: Date, calendar: Calendar = Calendar.getUTC()) -> Bool {
        let selfComps = calendar.dateComponents([.year, .month, .day], from: self)
        let targetComps = calendar.dateComponents([.year, .month, .day], from: date)
        return selfComps.year == targetComps.year &&
        selfComps.month == targetComps.month &&
        selfComps.day == targetComps.day
    }
}

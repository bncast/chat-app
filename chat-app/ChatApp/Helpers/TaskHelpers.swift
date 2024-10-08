//
//  TaskHelpers.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/23/24.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: TimeInterval) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}

//
//  ArrayHelpers.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import Foundation

extension Sequence where Element: Hashable {
    var toArray: [Element] { Array(self) }
}

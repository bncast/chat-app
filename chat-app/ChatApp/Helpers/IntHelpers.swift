//
//  IntHelpers.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

extension Int {
    init?(safe value: Any?) {
        if let intValue = value as? Int {
            self = intValue
            return
        } else if let strValue = value as? String {
            if let intValue = Int(strValue) {
                self = intValue
                return
            }
            if let doubleValue = Double(strValue), doubleValue < Double(Int.max) {
                self = Int(doubleValue)
                return
            }
            if let halfWidthString = strValue.applyingTransform(.fullwidthToHalfwidth, reverse: false),
               let intValue = Int(halfWidthString) {
                self = intValue
                return
            }
        }
        return nil
    }
}

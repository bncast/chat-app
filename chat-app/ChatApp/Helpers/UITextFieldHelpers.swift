//
//  UITextFieldHelpers.swift
//  ChatApp
//
//  Created by William Rena on 8/20/24.
//

import UIKit

extension UITextField {
    var cursorPosition: Int? {
        get {
            guard let selectedTextRange else { return nil }
            return offset(from: beginningOfDocument, to: selectedTextRange.start)
        }
        set {
            guard let newValue, let newPosition = position(from: beginningOfDocument, offset: newValue)
            else { return }
            selectedTextRange = textRange(from: newPosition, to: newPosition)
        }
    }
}


//
//  NSAttributedStringHelpers.swift
//  ChatApp
//
//  Created by William Rena on 8/20/24.
//

import UIKit
import Foundation

extension NSMutableAttributedString {
    @discardableResult
    func insertImage(_ image: UIImage?, position: Int = 0,
                     origin: CGPoint? = nil, size: CGSize? = nil,
                     color: UIColor? = nil) -> Self {
        let attachment = NSTextAttachment()
        attachment.image = image
        let imageFrame = CGRect(origin: origin ?? .zero,
                                size: size ?? image?.size ?? .zero)
        attachment.bounds = imageFrame
        let attributedImage = NSMutableAttributedString(attachment: attachment)
        guard let color else {
            insert(attributedImage, at: position)
            return self
        }
        attributedImage.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: 1))
        insert(attributedImage, at: position)
        return self
    }

    @discardableResult
    func setParagraphStyle(_ style: NSParagraphStyle, range: NSRange? = nil) -> Self {
        addAttribute(NSAttributedString.Key.paragraphStyle,
                     value: style,
                     range: range ?? NSRange(location: 0, length: string.count))
        return self
    }
}

extension NSMutableParagraphStyle {
    @discardableResult
    func setLineSpacing(_ lineSpacing: CGFloat) -> Self {
        self.lineSpacing = lineSpacing
        return self
    }

    @discardableResult
    func setLineHeight(_ lineHeight: CGFloat) -> Self {
        minimumLineHeight = lineHeight
        maximumLineHeight = lineHeight
        return self
    }

    @discardableResult
    func setLineBreakMode(_ lineBreakMode: NSLineBreakMode) -> Self {
        self.lineBreakMode = lineBreakMode
        return self
    }

    @discardableResult
    func setAlignment(_ alignment: NSTextAlignment) -> Self {
        self.alignment = alignment
        return self
    }
}

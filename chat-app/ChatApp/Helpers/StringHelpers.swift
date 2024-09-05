//
//  StringHelpers.swift
//  ChatApp
//

import UIKit

// MARK: - Convert string
extension String {
    func addingPercentEncoding() -> String? {
        let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
    }

    func getAttributedString(with font: UIFont,
                             color: UIColor? = .darkText,
                             attributes: [NSAttributedString.Key: Any]? = nil) -> NSMutableAttributedString {
        var attr: [NSAttributedString.Key: Any] = [.font: font]
        if let color {
            attr[.foregroundColor] = color
        }
        if let attributes {
            attr = attr.merging(attributes, uniquingKeysWith: { value1, _ -> Any in
                value1
            })
        }

        let attributedString = NSMutableAttributedString(string: self)

        // attributedのNSRangeのNSStringはutf-16がベースになっている。
        // 通常は指定しなくても問題ないが、絵文字を含むケースでは長さを指定しないと文字化けの原因になる。
        attributedString.addAttributes(attr, range: NSRange(location: 0, length: utf16.count))

        return attributedString
    }
}

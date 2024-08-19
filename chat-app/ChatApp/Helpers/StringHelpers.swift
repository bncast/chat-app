//
//  StringHelpers.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

extension String {
    func addingPercentEncoding() -> String? {
        let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
    }
}

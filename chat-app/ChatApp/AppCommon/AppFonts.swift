//
//  AppFonts.swift
//  chat-app
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import UIKit

extension UIFont {

    static var title: UIFont {
        .systemFont(ofSize: 25)
    }

    static var section: UIFont {
        .systemFont(ofSize: 20)
    }

    static var body: UIFont {
        .systemFont(ofSize: 18)
    }

    static var caption: UIFont {
        .systemFont(ofSize: 16)
    }
}
extension UIFont {
    func weight(_ weight: UIFont.Weight) -> UIFont {
        return .systemFont(ofSize: self.pointSize, weight: weight)
    }
}


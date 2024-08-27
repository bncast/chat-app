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

    static var captionSubtext: UIFont {
        .systemFont(ofSize: 14)
    }
}
extension UIFont {
    func bold() -> UIFont {
        return .systemFont(ofSize: self.pointSize, weight: .bold)
    }

    func semibold() -> UIFont {
        return .systemFont(ofSize: self.pointSize, weight: .semibold)
    }
}


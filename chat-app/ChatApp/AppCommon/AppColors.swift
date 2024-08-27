//
//  AppColors.swift
//  chat-app
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import UIKit

extension UIColor {
    static let background: (BackgroundColor) -> UIColor = { color in
        switch color {
        case .main: .main
        case .compose: .main
        case .profileImage: .accent
        case .delete: .systemRed
        case .accent: .accent
        case .mainLight: .mainBackground
        }
    }

    static let text: (TextColor) -> UIColor = { color in
        switch color {
        case .title: .text1
        case .caption: .subtext
        case .date: .textLight
        case .time: .textLight
        }
    }

    static let button: (ButtonColor) -> UIColor = { color in
        switch color {
        case .active: .main
        case .inactive: .mainBackground
        case .ongoing: .accentSecondary
        }
    }
}

enum BackgroundColor {
    case main
    case mainLight
    case compose
    case profileImage
    case delete
    case accent
}

enum TextColor {
    case title
    case caption
    case date
    case time
}

enum ButtonColor {
    case active
    case inactive
    case ongoing
}

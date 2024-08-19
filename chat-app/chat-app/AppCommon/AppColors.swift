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
        case .compose: .compose
        case .profileImage: .profile
        case .delete: .delete
        case .accent: .accent
        }
    }

    static let text: (TextColor) -> UIColor = { color in
        switch color {
        case .title: .title
        case .caption: .caption
        case .date: .date
        case .time: .time
        }
    }

    static let button: (ButtonColor) -> UIColor = { color in
        switch color {
        case .active: .active
        case .inactive: .inactive
        case .ongoing: .ongoing
        }
    }
}

enum BackgroundColor {
    case main
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

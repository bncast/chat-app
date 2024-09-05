//
//  UIViewControllerHelpers.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import UIKit

extension UIViewController {
    func addSubviews(_ views: [UIView]) {
        view.addSubviews(views)
    }

    func setNavigationBarDefaultStyle(backgroundColor: UIColor = .main, tintColor: UIColor = .mainBackground) {
        let image = UIImage(systemName: "chevron.left")
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.setBackIndicatorImage(image, transitionMaskImage: image)
            appearance.backgroundColor = backgroundColor
            appearance.shadowColor = .clear
            setNavigationBarAppearance(appearance)
        } else {
            let navigationBar = navigationController?.navigationBar
            navigationBar?.standardAppearance.setBackIndicatorImage(image, transitionMaskImage: image)
            navigationBar?.standardAppearance.backgroundColor = backgroundColor
            navigationBar?.standardAppearance.shadowColor = .clear
        }
        navigationController?.navigationBar.tintColor = tintColor
        navigationItem.backButtonTitle = ""
    }

    func setNavigationBarAppearance(_ appearance: UINavigationBarAppearance) {
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
}

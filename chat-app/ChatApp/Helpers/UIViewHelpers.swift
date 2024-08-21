//
//  UIViewHelpers.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import UIKit
import SuperEasyLayout

extension UIView {
    @discardableResult
    func addSubviews(_ views: [UIView]) -> UIView {
        views.forEach { addSubview($0) }
        return self
    }

    func setLayoutEqualTo(_ view: UIView, margins: UIEdgeInsets = .zero) {
        top == view.top + margins.top
        left == view.left + margins.left
        right == view.right - margins.right
        bottom == view.bottom - margins.bottom
    }

    func setLayoutEqualTo(_ view: UIView, space: CGFloat) {
        top == view.top + space
        left == view.left + space
        right == view.right - space
        bottom == view.bottom - space
    }

    func setLayoutEqualTo(
        _ view: UIView,
        leftMargin: CGFloat = 0,
        rightMargin: CGFloat = 0,
        topMargin: CGFloat = 0,
        bottomMargin: CGFloat = 0
    ) {
        top == view.top + topMargin
        left == view.left + leftMargin
        right == view.right - rightMargin
        bottom == view.bottom - bottomMargin
    }
}

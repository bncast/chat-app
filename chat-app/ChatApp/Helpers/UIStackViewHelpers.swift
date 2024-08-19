//
//  UIStackViewHelpers.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import UIKit

extension UIStackView {
    @discardableResult
    func addArrangedSubviews(_ views: [UIView]) -> UIStackView {
        views.forEach { addArrangedSubview($0) }
        return self
    }

    @discardableResult
    func removeArrangedSubviews(where handler: (() -> Bool)? = nil) -> UIStackView {
        arrangedSubviews.forEach { if handler?() ?? true { removeArrangedSubview($0) } }
        return self
    }
}

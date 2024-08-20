//
//  BaseNavigationBar.swift
//  ChatApp
//
//  Created by William Rena on 8/20/24.
//

import UIKit
import SuperEasyLayout

class BaseNavigationBar: UINavigationBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        setupLayout()
        setupConstraints()
        setupBindings()
        setupActions()
    }

    func setupLayout() {}
    func setupConstraints() {}
    func setupBindings() {}
    func setupActions() {}

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func setBackButtonConstraints(_ backButton: UIView, superview: UIView) {
        guard backButton.constraints.filter({ $0.identifier == "NewBackButtonLeftConstraint" }).isEmpty else { return }

        if #available(iOS 14, *) {
            guard let targetConstraint = backButton.constraints.filter({ $0.identifier == "Mask_Leading_Leading" }).first,
                  targetConstraint.isActive
            else { return }

            targetConstraint.isActive = false
        }

        let constraint = backButton.left ! .required == superview.left + 16
        backButton.width ! .required == 44
        constraint.identifier = "NewBackButtonLeftConstraint"
    }
}

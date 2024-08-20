//
//  BaseView.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import UIKit
import Combine

class BaseView: UIView {
    lazy var observers = [NSKeyValueObservation]()
    lazy var cancellables = Set<AnyCancellable>()

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
}

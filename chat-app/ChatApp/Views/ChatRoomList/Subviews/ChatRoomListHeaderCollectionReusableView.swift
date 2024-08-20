//
//  ClassroomListHeaderCollectionReusableView.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import UIKit
import SuperEasyLayout

class ChatRoomListHeaderCollectionReusableView: BaseCollectionReusableView {
    private lazy var leftSeparatorView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .active
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .callout
        view.textColor = .active
        return view
    }()

    private lazy var rightSeparatorView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .active
        return view
    }()

    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    override func setupLayout() {
        addSubviews([
            leftSeparatorView,
            titleLabel,
            rightSeparatorView
        ])
    }

    override func setupConstraints() {
        leftSeparatorView.left == left + 24.5
        leftSeparatorView.right == titleLabel.left - 8
        leftSeparatorView.centerY == centerY
        leftSeparatorView.height == 1

        titleLabel.centerX == centerX
        titleLabel.centerY == centerY

        rightSeparatorView.left == titleLabel.right + 8
        rightSeparatorView.right == right - 24.5
        rightSeparatorView.centerY == centerY
        rightSeparatorView.height == 1
    }
}

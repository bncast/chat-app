//
//  ClassroomListHeaderCollectionReusableView.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import UIKit
import SuperEasyLayout

class ChatRoomListHeaderCollectionReusableView: BaseCollectionReusableView {
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .body
        view.textColor = .textColor(.title)
        return view
    }()

    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    override func setupLayout() {
        addSubviews([
            titleLabel
        ])
    }

    override func setupConstraints() {
        titleLabel.left == left + 20
        titleLabel.right == right - 20
        titleLabel.centerY == centerY
    }
}

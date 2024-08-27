//
//  ChatRoomMessageHeaderCollectionReusableView.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/21/24.
//

import UIKit
import SuperEasyLayout

class ChatRoomMessageHeaderCollectionReusableView: BaseCollectionReusableView {
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .caption
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
        titleLabel.centerX == centerX
        titleLabel.centerY == centerY
    }
}

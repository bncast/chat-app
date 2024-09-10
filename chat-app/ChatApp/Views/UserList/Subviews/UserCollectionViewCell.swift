//
//  UserCollectionViewCell.swift
//  ChatApp
//
//  Created by William Rena on 8/26/24.
//

import UIKit
import SuperEasyLayout

class UserCollectionViewCell: BaseCollectionViewCell {
    private lazy var backView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()

    private lazy var nameTextLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .title
        view.textColor = .text
        view.lineBreakMode = .byCharWrapping
        return view
    }()

    private lazy var actionButton: BaseButton = {
        let view = BaseButton()
        view.colorStyle = .active
        view.layer.cornerRadius = 8
        return view
    }()

    var name: String? {
        get { nameTextLabel.text }
        set { nameTextLabel.text = newValue }
    }

    var isInvited: Bool? { didSet {
        guard let isInvited else { return }

        actionButton.backgroundColor = isInvited ? .button(.inactive) : .button(.active)
        actionButton.text = isInvited ? "INVITED" : "ADD"
        actionButton.colorStyle = isInvited ? .inactive : .active
    } }

    var inviteHandlerAsync: ((BaseButton) async -> Void)?

    // MARK: - Setups

    override func setupLayout() {
        contentView.addSubviews([
            backView.addSubviews([
                nameTextLabel,
                actionButton
            ])
        ])
    }

    override func setupConstraints() {
        backView.setLayoutEqualTo(contentView)

        nameTextLabel.left == backView.left + 20
        nameTextLabel.right == backView.right - 20
        nameTextLabel.top == backView.top + 20
        nameTextLabel.bottom == backView.bottom - 20

        actionButton.right == contentView.right - 20
        actionButton.centerY == contentView.centerY
        actionButton.width == 140
        actionButton.height == 44
    }

    override func setupActions() {
        actionButton.tapHandlerAsync = { [weak self] _ in
            guard let self, let inviteHandlerAsync else { return }
            await inviteHandlerAsync(actionButton)
        }
    }
}

//
//  InvitationCollectionViewCell.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/26/24.
//

import UIKit
import SuperEasyLayout

class InvitationCollectionViewCell: BaseCollectionViewCell {
    private lazy var chatRoomNameLabel: UILabel = {
        let view = UILabel()
        view.font = .section
        view.textColor = .textColor(.title)
        view.lineBreakMode = .byWordWrapping
        view.numberOfLines = 2
        return view
    }()

    private lazy var joinButton: BaseButton = {
        let view = BaseButton()
        view.text = "JOIN"
        view.colorStyle = .active
        view.layer.cornerRadius = 8
        return view
    }()

    var chatRoomName: String? {
        get { chatRoomNameLabel.text }
        set { chatRoomNameLabel.text = newValue }
    }

    var isInvited: Bool? { didSet {
        guard let isInvited else { return }
        joinButton.isHidden = !isInvited
    } }

    var joinTapHandlerAsync: ((BaseButton) async -> Void)?

    override func setupLayout() {
        contentView.addSubviews([
            chatRoomNameLabel,
            joinButton
        ])
    }

    override func setupConstraints() {
        chatRoomNameLabel.left == contentView.left + 20
        chatRoomNameLabel.right == joinButton.left - 20
        chatRoomNameLabel.top == contentView.top + 20
        chatRoomNameLabel.bottom == contentView.bottom - 20

        joinButton.right == contentView.right - 20
        joinButton.centerY == contentView.centerY
        joinButton.width == 80
        joinButton.height == 44
    }

    override func setupActions() {
        joinButton.tapHandlerAsync = { [weak self] _ in
            guard let self else { return }
            
            await joinTapHandlerAsync?(joinButton)
        }
    }

}

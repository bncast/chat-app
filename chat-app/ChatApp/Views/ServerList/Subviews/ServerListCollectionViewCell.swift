//
//  ServerListCollectionViewCell.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 9/9/24.
//

import UIKit
import SuperEasyLayout

class ServerListCollectionViewCell: BaseSwipeCollectionViewCell {
    typealias ConnectionStatus = ServerListViewModel.ConnectionStatus

    private lazy var backView = BaseView()

    var qrTapHandlerAsync: (() async -> Void)?

    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.font = .body
        view.textColor = .text
        return view
    }()

    private lazy var hostNameLabel: UILabel = {
        let view = UILabel()
        view.font = .captionSubtext
        view.textColor = .subtextLight
        return view
    }()

    private lazy var qrButton: BaseButton = {
        let view = BaseButton()
        view.setImage(UIImage(systemName: "qrcode.viewfinder"), for: .normal)
        view.backgroundColor = .clear
        view.tintColor = .subtextLight
        return view
    }()

    private lazy var connectionStatusLabel: UILabel = {
        let view = UILabel()
        view.font = .caption
        return view
    }()

    var name: String? {
        get { nameLabel.text }
        set { nameLabel.text = newValue }
    }

    var hostName: String? {
        get { hostNameLabel.text }
        set { hostNameLabel.text = newValue }
    }

    var connectionStatus: ConnectionStatus? { didSet {
        connectionStatusLabel.textColor = {
            switch connectionStatus {
            case .connected: .green
            case .available: .orange
            case .unavailable: .red
            case .none: .clear
            }
        }()
        connectionStatusLabel.text = connectionStatus?.rawValue
    } }

    override func setupLayout() {
        contentView.addSubviews([
            backView.addSubviews([
                nameLabel,
                hostNameLabel,
                qrButton,
                connectionStatusLabel
            ])
        ])
    }

    override func setupConstraints() {
        backView.setLayoutEqualTo(contentView)

        nameLabel.left == backView.left + 20
        nameLabel.top == connectionStatusLabel.top
        nameLabel.bottom == hostNameLabel.top

        hostNameLabel.left == nameLabel.left
        hostNameLabel.top == nameLabel.bottom
        hostNameLabel.bottom == connectionStatusLabel.bottom

        connectionStatusLabel.left == hostNameLabel.right + 20
        connectionStatusLabel.right == qrButton.left
        connectionStatusLabel.centerY == backView.centerY
        connectionStatusLabel.height == 44

        qrButton.left == connectionStatusLabel.right
        qrButton.right == backView.right
        qrButton.centerY == backView.centerY
        qrButton.width == 44
        qrButton.height == 44
    }

    override func setupActions() {
        selectionBackView = backView

        qrButton.tapHandlerAsync = { [weak self] _ in
            guard let self, let qrTapHandlerAsync else { return }
            await qrTapHandlerAsync()
        }
    }
}

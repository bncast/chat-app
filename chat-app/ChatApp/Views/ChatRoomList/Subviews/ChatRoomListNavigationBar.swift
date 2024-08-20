//
//  ClassroomListNavigationBar.swift
//  ChatApp
//
//  Created by William Rena on 8/20/24.
//

import UIKit
import SuperEasyLayout

class ChatRoomListNavigationBar: BaseNavigationBar {
    private(set) lazy var backView = BaseView()

    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "person.crop.circle.fill")?.withRenderingMode(.alwaysTemplate))
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        view.backgroundColor = .black
        view.layer.cornerRadius = 22
        return view
    }()

    private(set) lazy var invitationButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "envelope", withConfiguration: configuration)?.withRenderingMode(.alwaysTemplate)
        let view = BaseButton()
        view.setImage(image, for: .normal)
        view.layer.cornerRadius = 4
        return view
    }()

    var invitationTapHandler: ((UIButton) -> Void)?
    var invitationTapHandlerAsync: ((UIButton) async -> Void)?

    var profileTapHandler: ((UIImageView) -> Void)?
    var profileTapHandlerAsync: ((UIImageView) async -> Void)?

    override func setupLayout() {
        addSubviews([
            imageView,
            invitationButton
        ])
    }

    override func setupConstraints() {
        imageView.left == left + 22
        imageView.width == 44
        imageView.centerY == centerY
        imageView.height == 44

        invitationButton.right == right - 18
        invitationButton.width == 44
        invitationButton.centerY == centerY
        invitationButton.height == 44
    }

    override func setupActions() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapRecognizer)

        invitationButton.tapHandlerAsync = { [weak self] _ in
            guard let self else { return }
            if let invitationTapHandlerAsync {
                Task { [weak self] in
                    guard let self else { return }
                    await invitationTapHandlerAsync(invitationButton)
                }
            } else {
                invitationTapHandler?(invitationButton)
            }
        }
    }

    @objc
    private func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }

        if let profileTapHandlerAsync {
            Task { [weak self] in
                guard let self else { return }
                await profileTapHandlerAsync(imageView)
            }
        } else {
            profileTapHandler?(imageView)
        }
    }
}

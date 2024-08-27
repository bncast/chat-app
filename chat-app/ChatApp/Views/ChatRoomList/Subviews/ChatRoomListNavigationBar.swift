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

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .title
        view.textColor = UIColor.white
        view.textAlignment = .center
        return view
    }()

    private lazy var profileImageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "person.crop.circle.fill")?
            .withRenderingMode(.alwaysTemplate))
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        view.backgroundColor = .background(.mainLight)
        view.layer.cornerRadius = 22
        if let urlString = AppConstant.shared.currentUserImageUrlString {
            view.setImage(from: urlString)
        }
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    private(set) lazy var invitationButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "envelope", withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate)
        let view = BaseButton()
        view.tintColor = .background(.mainLight)
        view.setImage(image, for: .normal)
        view.layer.cornerRadius = 4
        return view
    }()

    private(set) lazy var moreButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "info.circle", withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate)
        let view = BaseButton()
        view.setImage(image, for: .normal)
        view.layer.cornerRadius = 4
        return view
    }()

    private(set) lazy var closeButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "xmark", withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate)
        let view = BaseButton()
        view.setImage(image, for: .normal)
        view.tintColor = .background(.mainLight)
        return view
    }()

    var showChatRoomListButtons: Bool = true { didSet {
        invitationButton.isHidden = false
        profileImageView.isHidden = false
        moreButton.isHidden = false
        closeButton.isHidden = false

        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.invitationButton.alpha = 1
            self?.profileImageView.alpha = 1
            self?.moreButton.alpha = 0
            self?.closeButton.alpha = 0
        } completion: { [weak self] _ in
            self?.moreButton.isHidden = true
            self?.closeButton.isHidden = true
        }
    } }

    var showChatRoomMessageButtons: Bool = true { didSet {
        invitationButton.isHidden = false
        profileImageView.isHidden = false
        moreButton.isHidden = false
        closeButton.isHidden = false

        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.invitationButton.alpha = 0
            self?.profileImageView.alpha = 0
            self?.closeButton.alpha = 0
            self?.moreButton.alpha = 1
        } completion: { [weak self] _ in
            self?.invitationButton.isHidden = true
            self?.profileImageView.isHidden = true
            self?.closeButton.isHidden = true
        }
    } }

    var showInvitaionListButtons: Bool = true { didSet {
        invitationButton.isHidden = false
        profileImageView.isHidden = false
        moreButton.isHidden = false
        closeButton.isHidden = false

        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.invitationButton.alpha = 0
            self?.profileImageView.alpha = 0
            self?.moreButton.alpha = 0
            self?.closeButton.alpha = 1
        } completion: { [weak self] _ in
            self?.invitationButton.isHidden = true
            self?.profileImageView.isHidden = true
            self?.moreButton.isHidden = true
        }
    } }

    var showCloseButtonOnly: Bool = true { didSet {
        profileImageView.isHidden = true
        closeButton.isHidden = false
        moreButton.isHidden = true
        invitationButton.isHidden = true
    } }

    var title: String = "" { didSet {
        titleLabel.text = title
    } }

    var invitationTapHandler: ((BaseButton) -> Void)?
    var invitationTapHandlerAsync: ((BaseButton) async -> Void)?

    var profileTapHandler: ((UIImageView) -> Void)?
    var profileTapHandlerAsync: ((UIImageView) async -> Void)?

    var moreTapHandler: ((BaseButton) -> Void)?
    var moreTapHandlerAsync: ((BaseButton) async -> Void)?

    var closeTapHandler: ((BaseButton) -> Void)?

    // MARK: - Setups

    override func setupLayout() {
        addSubviews([
            titleLabel,
            profileImageView,
            invitationButton,
            moreButton,
            closeButton
        ])

        titleTextAttributes = [NSAttributedString.Key.backgroundColor: UIColor.background(.mainLight),
                               NSAttributedString.Key.foregroundColor: UIColor.white,
                               NSAttributedString.Key.font: UIFont.body]
    }

    override func setupConstraints() {
        titleLabel.left == left + 74
        titleLabel.right == right - 74
        titleLabel.centerY == centerY
        titleLabel.height == 50

        profileImageView.left == left + 22
        profileImageView.width == 44
        profileImageView.centerY == centerY
        profileImageView.height == 44

        invitationButton.right == right - 18
        invitationButton.width == 44
        invitationButton.centerY == centerY
        invitationButton.height == 44

        moreButton.right == right - 18
        moreButton.width == 44
        moreButton.centerY == centerY
        moreButton.height == 44

        closeButton.right == right - 18
        closeButton.width == 44
        closeButton.centerY == centerY
        closeButton.height == 44
    }

    override func setupActions() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapRecognizer)

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

        moreButton.tapHandlerAsync = { [weak self] _ in
            guard let self else { return }

            if let moreTapHandlerAsync {
                Task { [weak self] in
                    guard let self else { return }

                    await moreTapHandlerAsync(moreButton)
                }
            } else {
                moreTapHandler?(moreButton)
            }
        }

        closeButton.tapHandler = { [weak self] _ in
            guard let self else { return }
            closeTapHandler?(closeButton)
        }

    }

    @objc
    private func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }

        if let profileTapHandlerAsync {
            Task { await profileTapHandlerAsync(imageView) }
        } else {
            profileTapHandler?(imageView)
        }
    }
}

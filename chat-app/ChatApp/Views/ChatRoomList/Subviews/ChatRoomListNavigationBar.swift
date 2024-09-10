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
        view.font = .title.semibold()
        view.textColor = UIColor.white
        view.textAlignment = .left
        return view
    }()
    private let iconPointSize: CGFloat = 25

    private(set) lazy var invitationButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: iconPointSize)
        let image = UIImage(systemName: "envelope", withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate)

        let view = BaseButton(image: image)
        view.tintColor = .background(.mainLight)
        view.setBackgroundColor(.clear, for: .normal)
        return view
    }()

    private(set) lazy var menuButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: iconPointSize)
        let image = UIImage(systemName: "gearshape", withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate)

        let view = BaseButton(image: image)
        view.tintColor = .background(.mainLight)
        view.setBackgroundColor(.clear, for: .normal)
        return view
    }()

    private(set) lazy var moreButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: iconPointSize)
        let image = UIImage(systemName: "info.circle", withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate)

        let view = BaseButton(image: image)
        view.tintColor = .background(.mainLight)
        view.setBackgroundColor(.clear, for: .normal)
        return view
    }()

    private(set) lazy var closeButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: iconPointSize)
        let image = UIImage(systemName: "xmark", withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate)

        let view = BaseButton(image: image)
        view.tintColor = .background(.mainLight)
        view.setBackgroundColor(.clear, for: .normal)
        return view
    }()

    var showChatRoomListButtons: Bool = true { didSet {
        invitationButton.isHidden = false
        menuButton.isHidden = false
        moreButton.isHidden = false
        closeButton.isHidden = false

        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.invitationButton.alpha = 1
            self?.menuButton.alpha = 1
            self?.moreButton.alpha = 0
            self?.closeButton.alpha = 0
        } completion: { [weak self] _ in
            self?.moreButton.isHidden = true
            self?.closeButton.isHidden = true
        }
    } }

    var showChatRoomMessageButtons: Bool = true { didSet {
        invitationButton.isHidden = false
        menuButton.isHidden = false
        moreButton.isHidden = false
        closeButton.isHidden = false

        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.invitationButton.alpha = 0
            self?.menuButton.alpha = 0
            self?.closeButton.alpha = 0
            self?.moreButton.alpha = 1
        } completion: { [weak self] _ in
            self?.invitationButton.isHidden = true
            self?.menuButton.isHidden = true
            self?.closeButton.isHidden = true
        }
    } }

    var showInvitationListButtons: Bool = true { didSet {
        invitationButton.isHidden = false
        menuButton.isHidden = false
        moreButton.isHidden = false
        closeButton.isHidden = false

        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.invitationButton.alpha = 0
            self?.menuButton.alpha = 0
            self?.moreButton.alpha = 0
            self?.closeButton.alpha = 1
        } completion: { [weak self] _ in
            self?.invitationButton.isHidden = true
            self?.menuButton.isHidden = true
            self?.moreButton.isHidden = true
        }
    } }

    var showCloseButtonOnly: Bool = true { didSet {
        menuButton.isHidden = true
        closeButton.isHidden = false
        moreButton.isHidden = true
        invitationButton.isHidden = true
    } }

    var title: String = "" { didSet {
        titleLabel.text = title
    } }

    var invitationTapHandler: ((BaseButton) -> Void)?
    var invitationTapHandlerAsync: ((BaseButton) async -> Void)?

    var menuTapHandler: ((BaseButton) -> Void)?
    var menuTapHandlerAsync: ((BaseButton) async -> Void)?

    var moreTapHandler: ((BaseButton) -> Void)?
    var moreTapHandlerAsync: ((BaseButton) async -> Void)?

    var closeTapHandler: ((BaseButton) -> Void)?

    // MARK: - Setups

    override func setupLayout() {
        addSubviews([
            titleLabel,
            menuButton,
            invitationButton,
            moreButton,
            closeButton
        ])

        titleTextAttributes = [NSAttributedString.Key.backgroundColor: UIColor.background(.mainLight),
                               NSAttributedString.Key.foregroundColor: UIColor.white,
                               NSAttributedString.Key.font: UIFont.body]
    }

    override func setupConstraints() {
        titleLabel.left == left + 42
        titleLabel.right == right - 74
        titleLabel.centerY == centerY
        titleLabel.height == 50

        menuButton.right == right - 18
        menuButton.width == 44
        menuButton.centerY == centerY
        menuButton.height == 44

        invitationButton.right == menuButton.left - 8
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
        menuButton.tapHandlerAsync = { [weak self] _ in
            guard let self else { return }

            if let menuTapHandlerAsync {
                Task { [weak self] in
                    guard let self else { return }

                    await menuTapHandlerAsync(menuButton)
                }
            } else {
                menuTapHandler?(invitationButton)
            }
        }

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
}

//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/20/24.
//

import UIKit
import SuperEasyLayout

class ProfileViewController: BaseViewController {
    private lazy var visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.effect = UIBlurEffect(style: .regular)
        return view
    }()

    private lazy var tapRecognizer: BaseTapGestureRecognizer = {
        let recognizer = BaseTapGestureRecognizer(on: visualEffectView)
        return recognizer
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .background(.main)
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.text = "User Profile"
        view.font = .largeTitle
        view.textColor = .title
        view.textAlignment = .center
        return view
    }()

    private lazy var closeButton: BaseButton = {
        let view = BaseButton()
        view.setImage(UIImage(systemName: "xmark"),for: .normal)
        view.tintColor = .text(.caption)
        return view
    }()

    private lazy var profileImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .background(.profileImage)
        view.layer.cornerRadius = 40
        return view
    }()

    private lazy var nameTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Display Name"
        view.borderStyle = .roundedRect
        return view
    }()

    private lazy var saveButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .button(.active)
        view.setTitle("SAVE", for: .normal)
        view.titleLabel?.textColor = .text(.caption)
        view.titleLabel?.font = .title3
        view.layer.cornerRadius = 8
        return view
    }()

    override func setupLayout() {
        view.backgroundColor = .clear

        addSubviews([
            visualEffectView,
            containerView.addSubviews([
                titleLabel,
                closeButton,
                profileImage,
                nameTextField,
                saveButton
            ])
        ])
    }

    override func setupConstraints() {
        visualEffectView.centerX == view.centerX
        visualEffectView.centerY == view.centerY
        visualEffectView.width == view.width
        visualEffectView.height == view.height

        containerView.width == AppConstant.screen(.width) - 40
        containerView.centerX == view.centerX
        containerView.centerY == view.centerY

        titleLabel.left == containerView.left + 20
        titleLabel.right == containerView.right - 20
        titleLabel.top == containerView.top + 20
        titleLabel.height == 40

        closeButton.right == containerView.right
        closeButton.top == containerView.top
        closeButton.width == 40
        closeButton.height == 40

        profileImage.centerX == containerView.centerX
        profileImage.top == titleLabel.bottom + 20
        profileImage.width == 80
        profileImage.height == 80

        nameTextField.left == containerView.left + 20
        nameTextField.right == containerView.right - 20
        nameTextField.top == profileImage.bottom + 20
        nameTextField.height == 30

        saveButton.left == containerView.left + 20
        saveButton.right == containerView.right - 20
        saveButton.top == nameTextField.bottom + 20
        saveButton.height == 40
        saveButton.bottom == containerView.bottom - 20
    }

    override func setupActions() {
        closeButton.tapHandler = { [weak self] _ in
            self?.dismiss(animated: true)
        }
        tapRecognizer.tapHandler = { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }

    static func show(on parentViewController: UIViewController) {
        let profileViewController = Self()
        profileViewController.modalPresentationStyle = .overFullScreen
        profileViewController.transitioningDelegate = profileViewController.fadeInAnimator
        parentViewController.present(profileViewController, animated: true)
    }
}

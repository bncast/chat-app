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

    private lazy var containerView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .background(.main)
        view.layer.cornerRadius = 12
        return view
    }()
    private weak var containerViewCenterYConstraint: NSLayoutConstraint?

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

    private lazy var nameTextField: BaseTextField = {
        let view = BaseTextField()
        view.placeholder = AppConstant.shared.isNewUser ? "Enter display name to register" : "Display Name"
        view.borderStyle = .roundedRect
        return view
    }()

    private lazy var saveButton: BaseButton = {
        let view = BaseButton()
        view.backgroundColor = .button(.active)
        view.setTitle("SAVE", for: .normal)
        view.titleLabel?.textColor = .text(.caption)
        view.titleLabel?.font = .title3
        view.layer.cornerRadius = 8
        return view
    }()

    private let viewModel = ProfileViewModel()

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
        visualEffectView.setLayoutEqualTo(view)

        containerView.width == AppConstant.shared.screen(.width) - 40
        containerView.centerX == view.centerX
        containerViewCenterYConstraint = containerView.centerY == view.centerY

        titleLabel.left == containerView.left + 20
        titleLabel.right == containerView.right - 20
        titleLabel.top == containerView.top + 20
        titleLabel.height == 40

        closeButton.right == containerView.right
        closeButton.top == containerView.top
        closeButton.width == 44
        closeButton.height == 44

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
        saveButton.height == 44
        saveButton.bottom == containerView.bottom - 20
    }

    override func setupBindings() {
        viewModel.$displayName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayName in
                self?.nameTextField.text = displayName
            }
            .store(in: &cancellables)
    }

    override func setupActions() {
        closeButton.tapHandler = { [weak self] _ in
            self?.dismiss(animated: true)
        }
        tapRecognizer.tapHandler = { [weak self] _ in
            self?.dismiss(animated: true)
        }
        saveButton.tapHandlerAsync = { [weak self] _ in
            do {
                guard let text = self?.nameTextField.text, !text.isEmpty else { return }

                self?.nameTextField.resignFirstResponder()
                await IndicatorController.shared.show()
                try await self?.viewModel.updateName(name: text)
                await IndicatorController.shared.dismiss()

                self?.viewModel.setDisplayName(name: text)
            } catch {
                print("\(error as! NetworkError)")
                await IndicatorController.shared.dismiss()
            }
        }

        keyboardAppear = self

        guard AppConstant.shared.isNewUser else { return }
        nameTextField.becomeFirstResponder()
    }

    static func show(on parentViewController: UIViewController) {
        let profileViewController = Self()
        profileViewController.modalPresentationStyle = .overFullScreen
        profileViewController.transitioningDelegate = profileViewController.fadeInAnimator
        profileViewController.viewModel.load()
        parentViewController.present(profileViewController, animated: true)
    }
}

extension ProfileViewController: ViewControllerKeyboardAppear {
    func willShowKeyboard(frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve) {
        containerViewCenterYConstraint?.constant = -abs((containerView.frame.height) - frame.height) - 44
        UIView.animate(withDuration: duration, delay: 0, options: curve.animationOptions) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func willHideKeyboard(frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve) {
        containerViewCenterYConstraint?.constant = 0
        UIView.animate(withDuration: duration, delay: 0, options: curve.animationOptions) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

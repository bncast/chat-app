//
//  PasswordViewController.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/10/24.
//

import UIKit
import SuperEasyLayout

class PasswordViewController: BaseViewController {
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
        view.backgroundColor = .background(.mainLight)
        view.layer.cornerRadius = 12
        return view
    }()
    private weak var containerViewCenterYConstraint: NSLayoutConstraint?

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.text = "Change Password"
        view.font = .title
        view.textColor = .textColor(.title)
        view.textAlignment = .center
        return view
    }()

    private lazy var oldPasswordTextField: FormTextField = {
        let view = FormTextField()
        view.title = "Old password"
//        view.textField.delegate = self
        return view
    }()
    
    private lazy var newPasswordTextField: FormTextField = {
        let view = FormTextField()
        view.title = "New password"
        //        view.textField.delegate = self
        return view
    }()

    private lazy var confirmPasswordTextField: FormTextField = {
        let view = FormTextField()
        view.title = "Confirm new password"
        //        view.textField.delegate = self
        return view
    }()


    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    private lazy var saveButton: BaseButton = {
        let view = BaseButton()
        view.text = "SAVE"
        view.colorStyle = .active
        view.layer.cornerRadius = 8
        return view
    }()
    private lazy var cancelButton: BaseButton = {
        let view = BaseButton()
        view.text = "CANCEL"
        view.colorStyle = .active
        view.layer.cornerRadius = 8
        return view
    }()

    private let viewModel = PasswordViewModel()
    private var continuation: CheckedContinuation<Void, Never>?

    // MARK: - Setups

    override func setupLayout() {
        view.backgroundColor = .clear

        addSubviews([
            visualEffectView,
            containerView.addSubviews([
                titleLabel,
                verticalStackView.addArrangedSubviews([
                    oldPasswordTextField,
                    newPasswordTextField,
                    confirmPasswordTextField,
                    saveButton,
                    cancelButton
                ])
            ])
        ])

        guard AppConstant.shared.deviceId == nil else { return }
        cancelButton.isHidden = true
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

        verticalStackView.left == containerView.left + 20
        verticalStackView.right == containerView.right - 20
        verticalStackView.top == titleLabel.bottom + 20
        verticalStackView.bottom == containerView.bottom - 20

        saveButton.height == 44
        cancelButton.height == 44
    }

    override func setupBindings() {
//        viewModel.$displayName
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] displayName in
//                self?.nameTextField.text = displayName
//            }
//            .store(in: &cancellables)
//
//        nameTextField.textPublisher
//            .sink { [weak self] text in
//                guard let text else { return }
//                self?.saveButton.isEnabled = !text.isEmpty
//            }
//            .store(in: &cancellables)
    }

    override func setupActions() {
        saveButton.tapHandlerAsync = { [weak self] _ in
//            await self?.updateProfile()
        }

//        nameTextField.onSubmitAsync = { [weak self] _ in
//            await self?.updateProfile()
//        }

        keyboardAppear = self


        cancelButton.tapHandler = { [weak self] _ in
            self?.dismiss(animated: true)
        }
        tapRecognizer.tapHandler = { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - View Controller

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        continuation?.resume()
    }

    // MARK: - Private Methods

    func updateProfile() async {
        do {
//            guard let text = nameTextField.text, !text.isEmpty else { return }
//            let statusBeforeUpdate = AppConstant.shared.deviceId == nil
//
//            nameTextField.resignFirstResponder()
//            await IndicatorController.shared.show()
////            setNewImage(urlString: try await viewModel.updateName(name: text))
//            await IndicatorController.shared.dismiss()
//            viewModel.setDisplayName(name: text)
//            await IndicatorController.shared.show(
//                message: "\(statusBeforeUpdate ? "Registered" : "Updated") Successfully!", isDone: true
//            )
//            await Task.sleep(seconds: 1)
//            await IndicatorController.shared.dismiss()
//            dismiss(animated: true)
        } catch {
            print("[ProfileViewController] \(error as! NetworkError)")
            await IndicatorController.shared.dismiss()
        }
    }
}

// MARK: - Navigation
extension PasswordViewController {
    static func show(on parentViewController: UIViewController) async {
        await withCheckedContinuation { continuation in
            let profileViewController = Self()
            profileViewController.modalPresentationStyle = .overFullScreen
            profileViewController.transitioningDelegate = profileViewController.fadeInAnimator
            profileViewController.continuation = continuation
            profileViewController.viewModel.load()
            parentViewController.present(profileViewController, animated: true)
        }
    }
}

// MARK: - Keyboard Appearance
extension PasswordViewController: ViewControllerKeyboardAppear {
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

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
        view.textField.isSecureTextEntry = true
        view.title = "Old password"
        return view
    }()
    
    private lazy var newPasswordTextField: FormTextField = {
        let view = FormTextField()
        view.textField.isSecureTextEntry = true
        view.title = "New password"
        return view
    }()

    private lazy var confirmPasswordTextField: FormTextField = {
        let view = FormTextField()
        view.textField.isSecureTextEntry = true
        view.title = "Confirm new password"
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
        view.text = "UPDATE"
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
        oldPasswordTextField.textField.textPublisher
            .sink { [weak self] text in
                self?.viewModel.oldPassword = text
            }
            .store(in: &cancellables)

        newPasswordTextField.textField.textPublisher
            .sink { [weak self] text in
                self?.viewModel.newPassword = text
            }
            .store(in: &cancellables)

        confirmPasswordTextField.textField.textPublisher
            .sink { [weak self] text in
                self?.viewModel.confirmPassword = text
            }
            .store(in: &cancellables)

        viewModel.$oldPasswordErrorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.oldPasswordTextField.message = errorMessage
            }
            .store(in: &cancellables)

        viewModel.$newPasswordErrorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.newPasswordTextField.message = errorMessage
            }
            .store(in: &cancellables)

        viewModel.$confirmPasswordErrorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.confirmPasswordTextField.message = errorMessage
            }
            .store(in: &cancellables)


    }

    override func setupActions() {
        oldPasswordTextField.textField.onSubmitAsync = { [weak self] _ in
            self?.newPasswordTextField.textField.becomeFirstResponder()
        }

        newPasswordTextField.textField.onSubmitAsync = { [weak self] _ in
            self?.confirmPasswordTextField.textField.becomeFirstResponder()
        }

        confirmPasswordTextField.textField.onSubmitAsync = { [weak self] _ in
            self?.updatePassword()
        }
        
        saveButton.tapHandlerAsync = { [weak self] _ in
            self?.updatePassword()
        }

        cancelButton.tapHandler = { [weak self] _ in
            self?.dismiss(animated: true)
        }

        tapRecognizer.tapHandler = { [weak self] _ in
            self?.dismiss(animated: true)
        }

        keyboardAppear = self
    }

    // MARK: - View Controller

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        continuation?.resume()
    }

    // MARK: - Private Methods

    func updatePassword() {
        Task {
            do {
                await IndicatorController.shared.show()
                guard try await viewModel.update() else {
                    return await IndicatorController.shared.dismiss()
                }
                await IndicatorController.shared.dismiss()
                await IndicatorController.shared.show(
                    message: "Updated successfully!", isDone: true
                )
                await Task.sleep(seconds: 1)
                await IndicatorController.shared.dismiss()
                dismiss(animated: true)
            } catch {
                print("[ProfileViewController] \(error as! NetworkError)")
                await IndicatorController.shared.dismiss()
            }
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

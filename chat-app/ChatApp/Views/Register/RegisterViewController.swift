//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/9/24.
//

import UIKit
import SuperEasyLayout

class RegisterViewController: BaseViewController {
    private lazy var closeButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "xmark", withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate)

        let view = BaseButton(image: image)
        view.tintColor = .background(.main)
        view.setBackgroundColor(.clear, for: .normal)
        return view
    }()

    private lazy var scrollView = UIScrollView()

    private lazy var backView: BaseView = {
        let view = BaseView()
        return view
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 8
        return view
    }()
    private var scrollViewBottomConstraint: NSLayoutConstraint?
    private var scrollViewHeightConstraint: NSLayoutConstraint?
    private var scrollViewCenterYConstraint: NSLayoutConstraint?

    private lazy var errorLabel: UILabel = {
        let view = UILabel()
        view.textColor = .red
        return view
    }()

    private lazy var displayNameField: FormTextField = {
        let view = FormTextField()
        view.title = "Display name"
        view.textField.delegate = self
        return view
    }()

    private lazy var usernameField: FormTextField = {
        let view = FormTextField()
        view.title = "Username"
        view.textField.delegate = self
        return view
    }()

    private lazy var passwordField: FormTextField = {
        let view = FormTextField()
        view.title = "Password"
        view.textField.isSecureTextEntry = true
        view.textField.delegate = self
        return view
    }()

    private lazy var confirmPasswordField: FormTextField = {
        let view = FormTextField()
        view.title = "Confirm Password"
        view.textField.isSecureTextEntry = true
        view.textField.delegate = self
        return view
    }()

    private lazy var submitButton: BaseButton = {
        let view = BaseButton()
        view.titleLabel?.textColor = .textColor(.caption)
        view.titleLabel?.font = .title
        view.text = "Register"
        view.layer.cornerRadius = 8
        return view
    }()

    private var viewModel = RegisterViewModel()

    override func setupLayout() {
        view.backgroundColor = .white

        addSubviews([
            closeButton,
            scrollView.addSubviews([
                backView.addSubviews([
                    stackView.addArrangedSubviews([
                        displayNameField,
                        usernameField,
                        passwordField,
                        confirmPasswordField,
                        submitButton
                    ])
                ])
            ])
        ])
    }

    override func setupConstraints() {
        closeButton.top == view.topMargin
        closeButton.left == view.left + 16
        closeButton.width == 40
        closeButton.height == 40

        scrollView.top == closeButton.bottom
        scrollView.left == view.left
        scrollView.right == view.right
        scrollViewBottomConstraint = scrollView.bottom <= view.bottom
        scrollViewHeightConstraint = scrollView.height == backView.height

        backView.setLayoutEqualTo(scrollView)
        backView.width == scrollView.width

        stackView.top == backView.top
        stackView.bottom == backView.bottom

        stackView.left == backView.left + 24
        stackView.right == backView.right - 24

        errorLabel.height == 20

        submitButton.height == 40
        submitButton.width == 250
    }

    override func setupBindings() {
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.errorLabel.text = errorMessage ?? ""
            }
            .store(in: &cancellables)

        observers.append(contentsOf: [
            displayNameField.textField.observe(\.text) { [weak self] field, changes in
                self?.viewModel.displayName = field.text
            },
            usernameField.textField.observe(\.text) { [weak self] field, changes in
                self?.viewModel.username = field.text
            },
            passwordField.textField.observe(\.text) { [weak self] field, changes in
                self?.viewModel.password = field.text
            },
            confirmPasswordField.textField.observe(\.text) { [weak self] field, changes in
                self?.viewModel.confirmPassword = field.text
            }
        ])
    }

    override func setupActions() {
        keyboardAppear = self

        BaseTapGestureRecognizer(on: view).tapHandler = { [weak self] _ in
            self?.view.endEditing(true)
        }

        closeButton.tapHandlerAsync =  { [weak self] _ in
            self?.dismiss(animated: true)
        }

        submitButton.tapHandlerAsync = { [weak self] _ in
            self?.view.endEditing(true)

            guard let self, viewModel.validate() else { return }

            await IndicatorController.shared.show()
            if await viewModel.submit() {
                ChatRoomListViewController.show(on: self)
            }
            await IndicatorController.shared.dismiss()
        }


    }

    static func show(on parentViewController: UIViewController) {
        let viewController = RegisterViewController()
        viewController.modalPresentationStyle = .fullScreen

        parentViewController.present(viewController, animated: true)
    }

    var originalHeight: CGFloat = 0
}

extension RegisterViewController: ViewControllerKeyboardAppear {
    func willShowKeyboard(frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve) {
//        originalHeight = scrollViewHeightConstraint?.constant ?? 0

//        scrollView.contentOffset = CGPoint(x: 0, y: -frame.height)
//        scrollViewCenterYConstraint?.constant =  -frame.height
//        scrollViewHeightConstraint?.constant =  originalHeight - frame.height
        UIView.animate(withDuration: duration, delay: 0, options: curve.animationOptions) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }

    func willHideKeyboard(frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve) {
        scrollViewBottomConstraint?.constant = 0
        scrollViewCenterYConstraint?.constant = 0
//        scrollViewHeightConstraint?.constant = originalHeight
        UIView.animate(withDuration: duration, delay: 0, options: curve.animationOptions) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

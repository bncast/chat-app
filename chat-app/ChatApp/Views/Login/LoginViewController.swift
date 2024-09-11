//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/9/24.
//

import UIKit
import SuperEasyLayout

class LoginViewController: BaseViewController {
    private lazy var serverListButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "server.rack", withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate)

        let view = BaseButton(image: image)
        view.tintColor = .background(.main)
        view.setBackgroundColor(.clear, for: .normal)
        return view
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 8
        return view
    }()
    private var stackViewCenterYConstraint: NSLayoutConstraint?

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = .splash
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var errorLabel: UILabel = {
        let view = UILabel()
        view.textColor = .red
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

    private lazy var loginButton: BaseButton = {
        let view = BaseButton()
        view.titleLabel?.textColor = .textColor(.caption)
        view.titleLabel?.font = .title
        view.text = "Login"
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var registerButton: BaseButton = {
        let view = BaseButton()
        view.titleLabel?.textColor = .textColor(.caption)
        view.titleLabel?.font = .title
        view.text = "Register"
        view.colorStyle = .inactive
        view.layer.cornerRadius = 8
        return view
    }()

    private var viewModel = LoginViewModel()

    override func setupLayout() {
        view.backgroundColor = .white

        addSubviews([
            serverListButton,
            stackView.addArrangedSubviews([
                imageView,
                errorLabel,
                usernameField,
                passwordField,
                loginButton,
                registerButton
            ])
        ])
    }

    override func setupConstraints() {
        serverListButton.top == view.topMargin
        serverListButton.right == view.right - 16
        serverListButton.width == 40
        serverListButton.height == 40

        stackView.left == view.left + 20
        stackView.right == view.right - 24
        stackViewCenterYConstraint = stackView.centerY == view.centerY

        imageView.height == 250

        errorLabel.height == 20
        loginButton.height == 40
        registerButton.height == 40

    }

    override func setupBindings() {
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.errorLabel.text = errorMessage ?? ""
            }
            .store(in: &cancellables)
    }

    override func setupActions() {
        keyboardAppear = self

        BaseTapGestureRecognizer(on: view).tapHandler = { [weak self] _ in
            self?.view.endEditing(true)
        }

        loginButton.tapHandlerAsync = { [weak self] _ in

            // TODO: Validation
            guard let self, let username = usernameField.textField.text,
                  let password = passwordField.textField.text,
                  !username.isEmpty, !password.isEmpty
            else { return }

            await IndicatorController.shared.show()
            if await viewModel.login(username: username, password: password) {
                await NotificationManager.shared.requestAuthorization()
                ChatRoomListViewController.show(on: self)
            }
            await IndicatorController.shared.dismiss()
        }

        registerButton.tapHandlerAsync = { [weak self] _ in
            guard let self else { return }

            RegisterViewController.show(on: self)
        }
    }

    static func show(on parentViewController: UIViewController) {
        let viewController = LoginViewController()
        viewController.modalPresentationStyle = .fullScreen

        parentViewController.present(viewController, animated: false)
    }
}

extension LoginViewController: ViewControllerKeyboardAppear {
    func willShowKeyboard(frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve) {
        stackViewCenterYConstraint?.constant =  -(frame.height / 1.7)
        UIView.animate(withDuration: duration, delay: 0, options: curve.animationOptions) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }

    func willHideKeyboard(frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve) {
        stackViewCenterYConstraint?.constant = 0
        UIView.animate(withDuration: duration, delay: 0, options: curve.animationOptions) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

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
        view.alignment = .center
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
        view.delegate = self
        return view
    }()

    private lazy var passwordField: FormTextField = {
        let view = FormTextField()
        view.title = "Password"
        view.isSecureTextEntry = true
        view.delegate = self
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

        stackView.left == view.left
        stackView.right == view.right
        stackViewCenterYConstraint = stackView.centerY == view.centerY

        imageView.height == 250

        errorLabel.height == 20

        loginButton.height == 40
        loginButton.width == 250

        registerButton.height == 40
        registerButton.width == 250
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
            guard let self, let username = usernameField.text,
                  let password = passwordField.text,
                  !username.isEmpty, !password.isEmpty
            else { return }

            await IndicatorController.shared.show()
            if await viewModel.login(username: username, password: password) == true {
                ChatRoomListViewController.show(on: self)
            }
            await IndicatorController.shared.dismiss()
        }

        registerButton.tapHandlerAsync = { [weak self] _ in
            print("NINOTEST REGISTER")
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
        stackViewCenterYConstraint?.constant =  -(frame.height / 2)
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

class FormTextField: BaseView {
    private var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .captionSubtext
        return label
    }()

    private var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    private var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .captionSubtext
        return label
    }()

    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    var message: String? {
        get { messageLabel.text }
    }

    var isSecureTextEntry: Bool {
        get { textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue}
    }

    var delegate: UITextFieldDelegate? {
        get { textField.delegate }
        set { textField.delegate = newValue }
    }

    private(set) var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }

    override func setupLayout() {
        addSubviews([
            stackView.addArrangedSubviews([
                titleLabel,
                textField,
                messageLabel
            ])
        ])
    }

    override func setupConstraints() {
        stackView.setLayoutEqualTo(self)

        textField.width == 250

        titleLabel.height == 20
        textField.height == 40
        messageLabel.height == 10

    }
}

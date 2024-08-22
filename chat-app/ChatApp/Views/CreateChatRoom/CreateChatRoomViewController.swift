//
//  CreateChatRoomViewController.swift
//  ChatApp
//
//  Created by William Rena on 8/21/24.
//

import UIKit
import SuperEasyLayout

class CreateChatRoomViewController: BaseViewController {
    private lazy var closeButton: BaseButton = {
        let view = BaseButton()
        view.setImage(UIImage(systemName: "xmark"),for: .normal)
        view.tintColor = .text(.caption)
        return view
    }()

    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 0
        view.alignment = .leading
        return view
    }()
    private weak var containerViewCenterYConstraint: NSLayoutConstraint?

    private lazy var titleTextLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.font = .titleBold
        view.textColor = .black
        view.lineBreakMode = .byCharWrapping
        view.text = "New Chat Room"
        return view
    }()

    private lazy var roomTextLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .body2
        view.textColor = .black
        view.lineBreakMode = .byCharWrapping
        view.text = "Room Name"
        return view
    }()

    private lazy var roomTextField: BaseTextField = {
        let view = BaseTextField()
        view.borderStyle = .roundedRect
        return view
    }()

    private lazy var passwordTextLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .body2
        view.textColor = .black
        view.lineBreakMode = .byCharWrapping
        view.text = "Password (optional)"
        return view
    }()

    private lazy var passwordTextField: BaseTextField = {
        let view = BaseTextField()
        view.borderStyle = .roundedRect
        view.isSecureTextEntry = true
        return view
    }()

    private lazy var createButton: BaseButton = {
        let view = BaseButton()
        view.backgroundColor = .button(.active)
        view.setTitle("CREATE", for: .normal)
        view.titleLabel?.textColor = .text(.caption)
        view.titleLabel?.font = .title3
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var cancelButton: BaseButton = {
        let view = BaseButton()
        view.backgroundColor = .button(.active)
        view.setTitle("CANCEL", for: .normal)
        view.titleLabel?.textColor = .text(.caption)
        view.titleLabel?.font = .title3
        view.layer.cornerRadius = 8
        return view
    }()

    let viewModel = CreateChatRoomViewModel()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }

    // MARK: - Setups

    override func setupLayout() {
        addSubviews([
            verticalStackView.addArrangedSubviews([
                titleTextLabel,
                roomTextLabel,
                roomTextField,
                passwordTextLabel,
                passwordTextField,
                createButton,
                cancelButton
            ])
        ])

        verticalStackView.setCustomSpacing(20, after: titleTextLabel)
        verticalStackView.setCustomSpacing(15, after: roomTextField)
        verticalStackView.setCustomSpacing(20, after: passwordTextField)
        verticalStackView.setCustomSpacing(10, after: createButton)
    }

    override func setupConstraints() {
        verticalStackView.width == 300
        verticalStackView.centerX == view.centerX
        containerViewCenterYConstraint = verticalStackView.centerY == view.centerY

        titleTextLabel.width == 300

        roomTextField.width == 300
        roomTextField.height == 44

        passwordTextField.width == 300
        passwordTextField.height == 44

        createButton.width == 300
        createButton.height == 44

        cancelButton.width == 300
        cancelButton.height == 44
    }

    override func setupActions() {
        roomTextField.becomeFirstResponder()
        keyboardAppear = self

        createButton.tapHandlerAsync = { [weak self] _ in
            await IndicatorController.shared.show()
            await IndicatorController.shared.dismiss()
            self?.dismiss(animated: true)
        }
        cancelButton.tapHandler = { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - Navigation
extension CreateChatRoomViewController {
    static func show(on parentViewController: UIViewController) {
        let viewController = CreateChatRoomViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen

        parentViewController.present(navigationController, animated: true)
    }
}

// MARK: Keyboard Appearance
extension CreateChatRoomViewController: ViewControllerKeyboardAppear {
    func willShowKeyboard(frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve) {
        containerViewCenterYConstraint?.constant = -abs((verticalStackView.frame.height) - frame.height) - 40
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

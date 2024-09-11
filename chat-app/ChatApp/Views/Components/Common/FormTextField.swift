//
//  FormTextField.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/9/24.
//

import UIKit
import SuperEasyLayout

class FormTextField: BaseView {
    private var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        return view
    }()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .captionSubtext
        return label
    }()

    var textField: BaseTextField = {
        let textField = BaseTextField()
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

//    var isSecureTextEntry: Bool {
//        get { textField.isSecureTextEntry }
//        set { textField.isSecureTextEntry = newValue}
//    }
//
//    var delegate: UITextFieldDelegate? {
//        get { textField.delegate }
//        set { textField.delegate = newValue }
//    }
//
//    var text: String? {
//        get { textField.text }
//        set { textField.text = newValue }
//    }

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

        textField.width == stackView.width

        titleLabel.height == 20
        textField.height == 40
        messageLabel.height == 10

    }
}

//
//  BaseTextField.swift
//  ChatApp
//
//  Created by William Rena on 8/20/24.
//

import UIKit
import Combine
import SuperEasyLayout

@objc protocol BaseTextFieldDelegate: NSObjectProtocol {
    @objc optional func tappedBackword(_ textField: BaseTextField)
}

class BaseTextField: UITextField {
    lazy var clearButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(
            systemName: "x.circle.fill", withConfiguration: configuration
        )?.withRenderingMode(.alwaysTemplate)

        let view = BaseButton(image: image)
        view.setBackgroundColor(.clear, for: .normal)
        view.width == 44
        view.height == 44
        view.tintColor = .textColor(.title)
        return view
    }()

    private lazy var hideButton: UIButton = {
        let button = BaseButton()
        button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        button.tintColor = .tertiaryLabel
        button.tapHandler = { [weak self] _ in
            guard let self, isSecureMode else { return }
            isHiding.toggle()
        }
        return button
    }()

    weak var baseTextFieldDelegate: BaseTextFieldDelegate?
    var leftViewWidth: CGFloat?
    var rightViewWidth: CGFloat?

    var isSelectable = true
    var maxLength: Int?
    var isKanjiConversioning: Bool { markedTextRange != nil }
    var rightViewRightMargin: CGFloat = 0

    /// Placeholder関連
    var placeholderFont: UIFont = .preferredFont(forTextStyle: .caption1)
    var placeholderColor: UIColor? = .tertiaryLabel
    override var placeholder: String? {
        get { attributedPlaceholder?.string }
        set {
            guard let newValue else {
                attributedPlaceholder = nil
                return
            }
            attributedPlaceholder = newValue
                .getAttributedString(with: placeholderFont,
                                     color: placeholderColor)
        }
    }

    weak var nextField: BaseTextField?
    var onBeginEdit: ((BaseTextField) -> Void)?
    var onSubmit: ((BaseTextField) -> Void)?
    var onSubmitAsync: ((BaseTextField) async -> Void)?
    var onChanged: ((BaseTextField, String?) -> Void)?
    var shouldClear: ((BaseTextField) -> Bool)?
    var shouldChangeHandler: ((BaseTextField, String, String, NSRange, String) -> (Int?, String?))?
    lazy var textPublisher: AnyPublisher<String?, Never> = _textPublisher.eraseToAnyPublisher()
    private let _textPublisher = PassthroughSubject<String?, Never>()
    @Published var hasFocus: Bool = false { willSet {
        isBorderHidden = !newValue
    } }

    override var text: String? {
        get { super.text }
        set {
            super.text = newValue
            onChangedText()
        }
    }

    var hasClearButton: Bool = false { didSet {
        guard hasClearButton else { return }

        rightViewWidth = 44
        rightView = clearButton
        rightViewMode = .always
        addSubview(clearButton)
        clearButton.right == right
        clearButton.centerY == centerY
        clearButton.isHidden = text?.isEmpty ?? true
        clearButton.tapHandler = { [weak self] _ in
            guard let self, delegate?.textFieldShouldClear?(self) ?? true,
                  shouldClear?(self) ?? true
            else { return }

            text = nil
            onChangedText()
        }
    } }

    var isSecureMode: Bool = false {
        didSet {
            guard isSecureMode, !oldValue, rightView !== hideButton else { return }

            isSecureTextEntry = true
            rightView = hideButton
            rightViewMode = .whileEditing
        }
    }

    var isHiding: Bool {
        get { isSecureMode ? isSecureTextEntry : false }
        set {
            guard isSecureMode else { return }

            isSecureTextEntry = newValue
            hideButton.setImage(UIImage(systemName: isSecureTextEntry ? "eye.fill" : "eye.slash.fill")?
                .withRenderingMode(.alwaysTemplate),
                                for: .normal)
        }
    }

    var isBorderHidden: Bool {
        get { layer.borderColor == UIColor.clear.cgColor }
        set { layer.borderColor = newValue ? UIColor.clear.cgColor : UIColor.main.cgColor }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addTarget(self, action: #selector(onChangedText), for: .editingChanged)
        delegate = self
        layer.borderWidth = 1
        layer.borderColor = UIColor.clear.cgColor

        setupLayout()
        setupConstraints()
        setupBindings()
        setupActions()
    }

    func setupLayout() {}
    func setupConstraints() {}
    func setupBindings() {}
    func setupActions() {}

    override func deleteBackward() {
        if text == "" { baseTextFieldDelegate?.tappedBackword?(self) }
        super.deleteBackward()
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let leftViewWidth else { return super.leftViewRect(forBounds: bounds) }

        return CGRect(x: 0.0, y: 0.0, width: leftViewWidth, height: bounds.height)
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let rightViewWidth else { return super.rightViewRect(forBounds: bounds) }

        return CGRect(
            x: bounds.width - rightViewWidth + rightViewRightMargin,
            y: 0.0,
            width: rightViewWidth,
            height: bounds.height
        )
    }

    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        isSecureMode ? [] : super.selectionRects(for: range)
    }

    @objc func onChangedText() {
        guard markedTextRange == nil else { return }

        if hasClearButton {
            clearButton.isHidden = text?.isEmpty ?? true
        }
        onChanged?(self, text)
        _textPublisher.send(text)
    }
}

extension BaseTextField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_: UITextField) -> Bool {
        onBeginEdit?(self)
        hasFocus = true
        return true
    }

    func textFieldShouldEndEditing(_: UITextField) -> Bool {
        hasFocus = false
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        hasFocus = false
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        if let next = nextField {
            next.becomeFirstResponder()
        } else {
            resignFirstResponder()
        }
        hasFocus = false
        if let onSubmitAsync {
            Task {
                await onSubmitAsync(self)
            }
        } else if let onSubmit {
            onSubmit(self)
        }
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn nsRange: NSRange,
                   replacementString string: String) -> Bool {
        guard let text,
              let range = Range(nsRange, in: text)
        else { return true }

        let newText = text.replacingCharacters(in: range, with: string)
        guard let handler = shouldChangeHandler else { return newText.count <= (maxLength ?? .max) }

        let (cursorPosition, newString) = handler(self, text, newText, nsRange, string)
        guard let cursorPosition, let newString else { return true }

        textField.text = newString
        textField.cursorPosition = cursorPosition

        return false
    }
}

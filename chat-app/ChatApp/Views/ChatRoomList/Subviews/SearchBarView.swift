//
//  SearchBarView.swift
//  ChatApp
//
//  Created by William Rena on 8/20/24.
//

import UIKit
import SuperEasyLayout
import Combine

class SearchBarView: BaseView {
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.backgroundColor = .clear
        return view
    }()

    private lazy var searchLeftView: BaseView = {
        let image = UIImage(systemName: "magnifyingglass.circle")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .accent

        let view = BaseView()
        view.addSubviews([imageView])
        imageView.left == view.left + 12
        imageView.width == 24
        imageView.centerY == view.centerY
        imageView.height == 24
        return view
    }()

    private lazy var searchTextField: BaseTextField = {
        let view = BaseTextField()

        view.placeholderFont = .body2
        view.placeholderColor = .black
        view.placeholder = "Search by name"

        view.backgroundColor = .white
        view.layer.cornerRadius = 22

        view.leftView = searchLeftView
        view.leftViewWidth = 40
        view.leftViewMode = .always

        view.hasClearButton = true
        view.rightViewWidth = 44
        view.autocapitalizationType = .none
        return view
    }()

    private lazy var containerView: BaseView = {
        let view = BaseView()
        view.addSubviews([searchTextField])
        searchTextField.left == view.left
        searchTextField.right == view.right
        searchTextField.top == view.top
        searchTextField.height == 44
        return view
    }()

    private lazy var errorLabel: UILabel = {
        let image = UIImage(systemName: "exclamationmark.triangle.fill")?.withRenderingMode(.alwaysTemplate)
        let view = UILabel()
        view.numberOfLines = 0
        view.lineBreakMode = .byCharWrapping
        view.attributedText = "Error"
            .getAttributedString(with: .callout, color: .red)
            .setParagraphStyle(NSMutableParagraphStyle().setLineSpacing(5))
            .insertImage(image, origin: CGPoint(x: 0, y: -5))
        view.isHidden = true
        return view
    }()

    var textPublisher: AnyPublisher<String?, Never> {
        searchTextField.textPublisher
    }

    var needToShowError = false { didSet {
        errorLabel.isHidden = !needToShowError
    } }

    override func setupLayout() {
        addSubviews([
            stackView.addArrangedSubviews([
                containerView,
                errorLabel
            ])
        ])
    }

    override func setupConstraints() {
        stackView.left == left + 10
        stackView.right == right - 10
        stackView.top == top
        stackView.bottom == bottom

        containerView.height == 44
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        searchTextField.resignFirstResponder()
    }

    func setInitTerm(_ term: String) {
        guard term != searchTextField.text else { return }
        searchTextField.text = term
    }
}

//
//  UserDeviceCollectionViewCell.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/11/24.
//

import UIKit
import SuperEasyLayout

class UserDeviceCollectionViewCell: BaseCollectionViewCell {
    private lazy var backView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()

    private lazy var separatorView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .subtextLight.withAlphaComponent(0.2)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .body
        view.textColor = .text
        view.lineBreakMode = .byCharWrapping
        return view
    }()

    private(set) lazy var deleteButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(systemName: "trash", withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate)

        let view = BaseButton(image: image)
        view.tintColor = .background(.main).withAlphaComponent(0.6)
        view.setBackgroundColor(.clear, for: .normal)
        return view
    }()

    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    var isFirst: Bool = false { didSet {
        guard isFirst else { return }

        separatorView.isHidden = true
    } }

    var deleteTapHandlerAsync: ((BaseButton) async -> ())?

    // MARK: - Setups

    override func setupLayout() {
        contentView.addSubviews([
            backView.addSubviews([
                separatorView,
                titleLabel,
                deleteButton
            ])
        ])
    }

    override func setupConstraints() {
        backView.setLayoutEqualTo(contentView)

        separatorView.top == backView.top
        separatorView.left == backView.left + 16
        separatorView.right == backView.right - 16
        separatorView.height == 1

        titleLabel.left == backView.left + 24
        titleLabel.right == backView.right - 24
        titleLabel.centerY == centerY

        deleteButton.right == backView.right - 24
        deleteButton.centerY == backView.centerY
    }

    override func setupActions() {
        deleteButton.tapHandlerAsync = { [weak self] button in
            await self?.deleteTapHandlerAsync?(button)
        }
    }
}

//
//  ClassroomCollectionViewCell.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import UIKit
import SuperEasyLayout

class ChatRoomListCollectionViewCell: BaseCollectionViewCell {
    private lazy var backView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "person.3.fill")?.withRenderingMode(.alwaysTemplate))
        view.contentMode = .scaleAspectFit
        view.tintColor = .red
        view.backgroundColor = .background(.profileImage)
        view.layer.cornerRadius = 25
        return view
    }()

    private lazy var horizontalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 15
        view.distribution = .fill
        view.alignment = .leading
        return view
    }()

    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 0
        view.alignment = .leading
        view.distribution = .fillProportionally
        return view
    }()

    private lazy var nameTextLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .body
        view.textColor = .textColor(.title)
        view.lineBreakMode = .byCharWrapping
        return view
    }()

    private lazy var previewTextLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .caption
        view.textColor = .textColor(.caption)
        view.lineBreakMode = .byTruncatingTail
        return view
    }()

    private lazy var detailImageView: UIImageView = {
        let image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        let view = UIImageView(image: image)
        view.contentMode = .center
        view.tintColor = .background(.accent)
        return view
    }()

    var name: String? {
        get { nameTextLabel.text }
        set { nameTextLabel.text = newValue }
    }

    var preview: String? {
        get { previewTextLabel.text }
        set { previewTextLabel.text = newValue }
    }

    // MARK: - Setups

    override func setupLayout() {
        contentView.addSubviews([
            backView.addSubviews([
                horizontalStackView.addArrangedSubviews([
                    imageView,
                    verticalStackView.addArrangedSubviews([
                        nameTextLabel,
                        previewTextLabel
                    ])
                ])
            ])
        ])
    }

    override func setupConstraints() {
        backView.setLayoutEqualTo(contentView)

        horizontalStackView.left == backView.left + 20
        horizontalStackView.right == backView.right - 20
        horizontalStackView.top == backView.top + 10
        horizontalStackView.bottom == backView.bottom - 10

        nameTextLabel.compressionRegistanceVerticalPriority = .required
        previewTextLabel.compressionRegistanceVerticalPriority = .required

        verticalStackView.centerY == horizontalStackView.centerY

        imageView.width == 50
        imageView.height == 50
    }

    override func setupActions() {
        selectionBackView = backView
    }
}

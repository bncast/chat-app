//
//  ChatRoomMessageCollectionViewCell.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/21/24.
//

import UIKit
import SuperEasyLayout

class ChatRoomMessageCollectionViewCell: BaseCollectionViewCell {
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
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()

    private lazy var horizontalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.distribution = .fill
        view.alignment = .leading
        return view
    }()

    private lazy var contentBackView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .accentSecondary
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var longPressRecognizer: BaseLongPressGestureRecognizer = {
        let recognizer = BaseLongPressGestureRecognizer(on: contentBackView)
        return recognizer
    }()

    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.alignment = .leading
        view.distribution = .fillProportionally
        return view
    }()

    private lazy var contentLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .section
        view.textColor = .text
        view.lineBreakMode = .byCharWrapping
        return view
    }()

    private lazy var labelHorizontalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.distribution = .fill
        view.alignment = .leading
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .caption.semibold()
        view.textColor = .subtext
        view.lineBreakMode = .byTruncatingTail
        return view
    }()

    private lazy var timeLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .caption
        view.textColor = .subtext
        view.lineBreakMode = .byTruncatingTail
        return view
    }()

    var content: String? {
        get { contentLabel.text }
        set { contentLabel.text = newValue }
    }

    var name: String? {
        get { nameLabel.text }
        set { nameLabel.text = newValue }
    }

    var time: String? {
        get { timeLabel.text }
        set { timeLabel.text = newValue }
    }

    var imageUrlString: String? { didSet {
        guard let imageUrlString else { return }
        imageView.setImage(from: imageUrlString)
    } }

    var isCurrentUser: Bool = false { didSet {
        guard isCurrentUser else { return }

        imageView.isHidden = true
        rightConstraint?.isActive = true
        leftConstraint?.isActive = false

        contentBackView.backgroundColor = .accent
        contentLabel.textColor = .textLight
        timeLabel.textColor = .subtextLight

        nameLabel.isHidden = true
    } }

    var showOptionsHandler: ((BaseView) async -> Void)?

    // MARK: - Setups

    override func setupLayout() {
        contentView.addSubviews([
            backView.addSubviews([
                horizontalStackView.addArrangedSubviews([
                    imageView,
                    contentBackView.addSubviews([
                        verticalStackView.addArrangedSubviews([
                            contentLabel,
                            labelHorizontalStackView.addArrangedSubviews([
                                nameLabel,
                                timeLabel
                            ])
                        ])
                    ])
                ])
            ])
        ])
    }

    var leftConstraint: NSLayoutConstraint?
    var rightConstraint: NSLayoutConstraint?

    override func setupConstraints() {
        leftConstraint = backView.left == contentView.left
        rightConstraint = backView.right == contentView.right
        backView.top == contentView.top
        backView.bottom == contentView.bottom

        rightConstraint?.isActive = false

        horizontalStackView.setLayoutEqualTo(backView, space: 10)

        contentLabel.compressionRegistanceVerticalPriority = .required
        nameLabel.compressionRegistanceVerticalPriority = .required

        verticalStackView.setLayoutEqualTo(contentBackView, space: 10)

        imageView.width == 50
        imageView.height == 50
    }

    override func setupActions() {
        selectionBackView = backView

        longPressRecognizer.longPressHandler = { [weak self] _ in
            Task {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
                guard let self, let showOptionsHandler = self.showOptionsHandler else { return }
                await showOptionsHandler(self.contentBackView)
            }
        }
    }

}

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
        view.alignment = .bottom
        return view
    }()

    private lazy var verticalContentsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        return view
    }()

    private lazy var replyToContentBackView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .mainBackground
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var replyToNameBackView = BaseView()

    private lazy var replyToNameLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .captionSubtext
        view.textColor = .subtext
        view.numberOfLines = 3
        view.lineBreakMode = .byTruncatingTail
        return view
    }()

    private lazy var replyToContentLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .caption
        view.textColor = .subtext
        view.numberOfLines = 3
        view.lineBreakMode = .byTruncatingTail
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
        view.distribution = .equalSpacing
        return view
    }()

    private lazy var contentLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .section
        view.textColor = .text
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
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

    var replyToContent: String? {
        get { replyToContentLabel.text }
        set { replyToContentLabel.text = newValue }
    }

    var replyToName: String? {
        get { replyToNameLabel.text }
        set { replyToNameLabel.text = newValue }
    }

    var imageUrlString: String? { didSet {
        guard let imageUrlString else { return }
        imageView.setImage(from: imageUrlString)
    } }

    var isCurrentUser: Bool = false { didSet {
        guard isCurrentUser else { return }

        imageView.isHidden = true
        rightConstraint?.isActive = true
        leftSecondaryConstraint?.isActive = true

        leftConstraint?.isActive = false
        rightSecondaryConstraint?.isActive = false

        verticalStackView.alignment = .trailing

        contentBackView.backgroundColor = .accent
        contentLabel.textColor = .textLight
        timeLabel.textColor = .subtextLight

        verticalContentsStackView.alignment = .trailing

        nameLabel.isHidden = true
    } }

    var showOptionsHandler: ((BaseView) async -> Void)?

    // MARK: - Setups

    override func setupLayout() {
        contentView.addSubviews([
            backView.addSubviews([
                horizontalStackView.addArrangedSubviews([
                    imageView,
                    verticalContentsStackView.addArrangedSubviews([
                        replyToNameBackView.addSubviews([replyToNameLabel]),
                        replyToContentBackView.addSubviews([replyToContentLabel]),
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
        ])

        verticalContentsStackView.setCustomSpacing(-18, after: replyToContentBackView)
    }

    var leftConstraint: NSLayoutConstraint?
    var rightConstraint: NSLayoutConstraint?

    var leftSecondaryConstraint: NSLayoutConstraint?
    var rightSecondaryConstraint: NSLayoutConstraint?

    override func setupConstraints() {
        leftConstraint = backView.left == contentView.left
        rightConstraint = backView.right == contentView.right

        leftSecondaryConstraint = backView.left >= contentView.left  + 100
        rightSecondaryConstraint = backView.right <= contentView.right - 100

        backView.top == contentView.top
        backView.bottom == contentView.bottom

        rightConstraint?.isActive = false
        leftSecondaryConstraint?.isActive = false

        horizontalStackView.setLayoutEqualTo(backView, space: 10)

        contentLabel.compressionRegistanceVerticalPriority = .required
        nameLabel.compressionRegistanceVerticalPriority = .required

        verticalStackView.setLayoutEqualTo(contentBackView, space: 10)

        replyToContentLabel.compressionRegistanceVerticalPriority = .required

        replyToContentLabel.left == replyToContentBackView.left + 10
        replyToContentLabel.right == replyToContentBackView.right - 10
        replyToContentLabel.top == replyToContentBackView.top + 10
        replyToContentLabel.bottom == replyToContentBackView.bottom - 20
        replyToContentLabel.width <= replyToContentBackView.width * 0.92

        replyToNameLabel.compressionRegistanceVerticalPriority = .required

        replyToNameLabel.left == replyToNameBackView.left
        replyToNameLabel.right == replyToNameBackView.right
        replyToNameLabel.top == replyToNameBackView.top
        replyToNameLabel.bottom == replyToNameBackView.bottom

        imageView.width == 50
        imageView.height == 50
    }

    override func setupActions() {
        selectionBackView = backView

        longPressRecognizer.longPressHandler = { [weak self] gesture in
            guard gesture.state == .began else { return }

            Task {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
                guard let self, let showOptionsHandler = self.showOptionsHandler else { return }
                await showOptionsHandler(self.contentBackView)
            }
        }
    }

    func hideReplyTo() {
        replyToNameBackView.isHidden = true
        replyToContentBackView.isHidden = true
    }

}

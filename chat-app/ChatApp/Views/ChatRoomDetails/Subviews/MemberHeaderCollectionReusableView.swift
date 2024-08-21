//
//  MemberHeaderCollectionReusableView.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/21/24.
//

import UIKit
import SuperEasyLayout

class MemberHeaderCollectionReusableView: BaseCollectionReusableView {
    private lazy var profileImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .background(.profileImage)
        view.layer.cornerRadius = 40
        return view
    }()

    private lazy var titleBackgroundView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .active
        return view
    }()

    private lazy var titleTapView: BaseView = {
        let view = BaseView()
        return view
    }()

    private lazy var tapRecognizer: BaseTapGestureRecognizer = {
        let recognizer = BaseTapGestureRecognizer(on: titleTapView)
        return recognizer
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .largeTitle
        view.textColor = .title
        view.textAlignment = .center
        return view
    }()
    private weak var titleLabelWidthConstraint: NSLayoutConstraint?

    private lazy var titleEditImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "pencil")
        view.contentMode = .top
        view.tintColor = .background(.accent)
        return view
    }()

    private lazy var memberLabel: UILabel = {
        let view = UILabel()
        view.text = "Members"
        view.font = .largeTitle
        view.textColor = .title
        view.textAlignment = .center
        return view
    }()

    var title: String? {
        get { titleLabel.text }
        set {
            titleLabel.text = newValue
            titleLabel.sizeToFit()
            titleLabelWidthConstraint?.constant = titleLabel.frame.size.width > frame.size.width - 40 ? frame.size.width - 40 : titleLabel.frame.size.width
            layoutIfNeeded()
        }
    }

    var editHandler: ((String) async -> String)?
    var editNameInServerHandler: ((String) async -> String?)?

    override func setupLayout() {
        addSubviews([
            profileImage,
            titleBackgroundView,
            titleTapView.addSubviews([
                titleLabel,
                titleEditImageView
            ]),
            memberLabel
        ])
    }

    override func setupConstraints() {
        profileImage.centerX == centerX
        profileImage.top == top + 20
        profileImage.width == 80
        profileImage.height == 80

        titleLabel.left == titleTapView.left
        titleLabel.top == titleTapView.top
        titleLabel.bottom == titleTapView.bottom
        titleLabelWidthConstraint = titleLabel.width == 0

        titleEditImageView.left == titleLabel.right
        titleEditImageView.top == titleTapView.top
        titleEditImageView.bottom == titleTapView.bottom
        titleEditImageView.width == 20

        titleTapView.centerX == centerX
        titleTapView.height == 44
        titleTapView.width == titleLabel.width

        titleBackgroundView.left == left
        titleBackgroundView.right == right
        titleBackgroundView.bottom == titleTapView.bottom
        titleBackgroundView.height == 44

        memberLabel.right == right
        memberLabel.left == left
        memberLabel.top == titleTapView.bottom
        memberLabel.bottom == bottom
        memberLabel.height == 64
    }

    override func setupActions() {
        tapRecognizer.tapHandlerAsync = { [weak self] _ in
            guard let self, let editHandler, let currentTitle = title else { return }

            let newTitle = await editHandler(currentTitle)
            guard newTitle != title, !newTitle.isEmpty,
                  let editNameInServerHandler,
                  let titleFromServer = await editNameInServerHandler(newTitle) else { return }

            title = titleFromServer
        }
    }
}

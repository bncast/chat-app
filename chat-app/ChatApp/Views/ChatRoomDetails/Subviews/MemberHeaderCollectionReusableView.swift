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
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()

    private lazy var titleTapView: BaseView = BaseView()

    private lazy var tapRecognizer: BaseTapGestureRecognizer = BaseTapGestureRecognizer(on: titleTapView)

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .title
        view.textColor = .background(.accent)
        view.textAlignment = .center
        return view
    }()
    private weak var titleLabelWidthConstraint: NSLayoutConstraint?

    private lazy var titleEditImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "pencil")
        view.contentMode = .scaleAspectFit
        view.tintColor = .background(.accent)
        return view
    }()

    var imageUrlString: String? { didSet{
        guard let imageUrlString else { return }
        profileImage.setImage(from: imageUrlString)
    } }

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
            titleTapView.addSubviews([
                titleLabel,
                titleEditImageView
            ]),
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
        titleEditImageView.centerY == titleLabel.centerY
        titleEditImageView.width == 25
        titleEditImageView.height == 25

        titleTapView.centerX == centerX
        titleTapView.height == 44
        titleTapView.width == titleLabel.width
        titleTapView.bottom == bottom - 20
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

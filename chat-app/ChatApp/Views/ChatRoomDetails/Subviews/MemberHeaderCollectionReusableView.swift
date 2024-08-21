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

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .largeTitle
        view.textColor = .title
        view.textAlignment = .center
        view.backgroundColor = .active
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
        set { titleLabel.text = newValue }
    }

    override func setupLayout() {
        addSubviews([
            profileImage,
            titleLabel,
            memberLabel
        ])
    }

    override func setupConstraints() {
        profileImage.centerX == centerX
        profileImage.top == top + 20
        profileImage.width == 80
        profileImage.height == 80

        titleLabel.right == right + 20
        titleLabel.left == left - 20
        titleLabel.height == 44

        memberLabel.right == right
        memberLabel.left == left
        memberLabel.top == titleLabel.bottom
        memberLabel.bottom == bottom
        memberLabel.height == 64
    }
}

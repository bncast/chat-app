//
//  MemberWithStatusCollectionViewCell.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/21/24.
//

import UIKit
import SuperEasyLayout

class MemberWithStatusCollectionViewCell: BaseCollectionViewCell {
    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.font = .title2
        view.textColor = .black
        view.lineBreakMode = .byCharWrapping
        return view
    }()

    private lazy var adminButton: BaseButton = {
        let view = BaseButton()
        view.titleLabel?.textColor = .text(.caption)
        view.titleLabel?.font = .title3
        view.layer.cornerRadius = 8
        return view
    }()

    var name: String? {
        get { nameLabel.text }
        set { nameLabel.text = newValue }
    }

    var isAdmin: Bool? { didSet {
        guard let isAdmin else { return }
        adminButton.backgroundColor = isAdmin ? .button(.inactive) : .button(.active)
        adminButton.setTitle(isAdmin ? "ADMIN" : "NOT ADMIN", for: .normal)
    } }

    var roomUserId: Int?

    var setIsAdminInServerHandler: ((Bool) async -> Bool?)?

    override func setupLayout() {
        contentView.addSubviews([
            nameLabel,
            adminButton
        ])
    }

    override func setupConstraints() {
        nameLabel.left == contentView.left + 20
        nameLabel.right == adminButton.left - 20
        nameLabel.top == contentView.top + 20
        nameLabel.bottom == contentView.bottom - 20

        adminButton.right == contentView.right - 20
        adminButton.centerY == contentView.centerY
        adminButton.width == 140
        adminButton.height == 44
    }

    override func setupActions() {
        adminButton.tapHandlerAsync = { [weak self] _ in
            guard let self, let setIsAdminInServerHandler, let isAdmin,
                  let updatedIsAdmin = await setIsAdminInServerHandler(!isAdmin) else { return }

            self.isAdmin = updatedIsAdmin
        }
    }
}

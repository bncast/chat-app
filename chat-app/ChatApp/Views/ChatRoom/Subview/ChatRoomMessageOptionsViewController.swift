//
//  ChatRoomMessageOptionsViewController.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/22/24.
//

import UIKit
import SuperEasyLayout

class ChatRoomMessageOptionsViewController: BaseViewController {

    enum ChatOptions {
        case reply, edit, delete, none
    }

    private lazy var visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.effect = UIBlurEffect(style: .regular)
        return view
    }()

    private lazy var tapRecognizer: BaseTapGestureRecognizer = {
        let recognizer = BaseTapGestureRecognizer(on: visualEffectView)
        return recognizer
    }()

    private lazy var messageContent = UIView()
    private var messageContentPoint: CGPoint?

    private lazy var containerView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .mainBackground
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()

    private lazy var replyButton: BaseButton = {
        let view = BaseButton()
        view.backgroundColor = .button(.active)
        view.setTitle("REPLY", for: .normal)
        view.titleLabel?.textColor = .textLight
        view.titleLabel?.font = .section
        return view
    }()

    private lazy var editButton: BaseButton = {
        let view = BaseButton()
        view.backgroundColor = .button(.active)
        view.setTitle("EDIT", for: .normal)
        view.titleLabel?.textColor = .textLight
        view.titleLabel?.font = .section
        view.clipsToBounds = true
        return view
    }()

    private lazy var deleteButton: BaseButton = {
        let view = BaseButton()
        view.backgroundColor = .button(.active)
        view.setTitle("DELETE", for: .normal)
        view.titleLabel?.textColor = .textLight
        view.titleLabel?.font = .section
        return view
    }()

    private var isCurrentUser: Bool?
    private var continuation: CheckedContinuation<ChatOptions, Never>?

    override func setupLayout() {
        view.backgroundColor = .clear

        addSubviews([
            visualEffectView,
            messageContent,
            containerView.addSubviews([
                replyButton,
                editButton,
                deleteButton
            ])
        ])
    }

    override func setupConstraints() {
        guard let messageContentPoint, let isCurrentUser else { return }
        visualEffectView.setLayoutEqualTo(view)


        messageContent.left == view.left + messageContentPoint.x
        messageContent.top == view.top + messageContentPoint.y
        messageContent.width == messageContent.frame.size.width
        messageContent.height == messageContent.frame.size.height

        containerView.top == messageContent.bottom + 8
        containerView.width == AppConstant.shared.screen(.width) * 0.6
        if messageContentPoint.x > 100 {
            containerView.right == view.right - 10
        } else {
            containerView.left == view.left + 10
        }

        replyButton.left == containerView.left
        replyButton.right == containerView.right
        replyButton.top == containerView.top
        replyButton.height == 44

        editButton.left == containerView.left
        editButton.right == containerView.right
        editButton.top == replyButton.bottom + (isCurrentUser ? 1 : .zero)
        editButton.height == (isCurrentUser ? 44 : .zero)

        deleteButton.left == containerView.left
        deleteButton.right == containerView.right
        deleteButton.top == editButton.bottom + 1
        deleteButton.bottom == containerView.bottom
    }

    override func setupActions() {
        tapRecognizer.tapHandler = { [weak self] _ in
            guard let self, let continuation else { return }
            continuation.resume(returning: .none)
            dismiss(animated: true)
        }
        replyButton.tapHandlerAsync = { [weak self] _ in
            guard let self, let continuation else { return }
            continuation.resume(returning: .reply)
            dismiss(animated: true)
        }
        editButton.tapHandlerAsync = { [weak self] _ in
            guard let self, let continuation else { return }
            continuation.resume(returning: .edit)
            dismiss(animated: true)
        }
        deleteButton.tapHandlerAsync = { [weak self] _ in
            guard let self, let continuation else { return }
            continuation.resume(returning: .delete)
            dismiss(animated: true)
        }
    }

    static func show(on parentViewController: UIViewController,
                     with messageViewSnapshot: UIView, and isCurrentUser: Bool,
                     at point: CGPoint) async -> ChatOptions {
        await withCheckedContinuation { continuation in
            let chatRoomMessageOptionsViewController = Self()
            chatRoomMessageOptionsViewController.modalPresentationStyle = .overFullScreen
            chatRoomMessageOptionsViewController.transitioningDelegate = chatRoomMessageOptionsViewController.fadeInAnimator
            chatRoomMessageOptionsViewController.messageContent = messageViewSnapshot
            chatRoomMessageOptionsViewController.messageContentPoint = point
            chatRoomMessageOptionsViewController.isCurrentUser = isCurrentUser
            chatRoomMessageOptionsViewController.continuation = continuation
            parentViewController.present(chatRoomMessageOptionsViewController, animated: true)
        }
    }
}

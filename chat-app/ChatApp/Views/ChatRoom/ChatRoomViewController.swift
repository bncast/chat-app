//
//  ChatRoomViewController.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/21/24.
//

import UIKit
import SuperEasyLayout

class ChatRoomViewController: BaseViewController {
    private typealias Section = ChatRoomViewModel.Section
    private typealias Item = ChatRoomViewModel.Item
    private typealias ItemInfo = ChatRoomViewModel.MessageInfo
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    private var dataSource: DataSource?

    private lazy var layout: UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { [weak self] _, _ in
            self?.getSectionLayout()
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundView = nil
        view.backgroundColor = .white

        ChatRoomMessageCollectionViewCell.registerCell(to: view)
        ChatRoomMessageHeaderCollectionReusableView.registerView(to: view)
        return view
    }()

    private lazy var tapRecognizer: BaseTapGestureRecognizer = {
        let recognizer = BaseTapGestureRecognizer(on: collectionView)
        return recognizer
    }()

    private lazy var replyingToView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .background(.main)
        view.clipsToBounds = true
        return view
    }()
    private weak var replyingToViewHeightConstraint: NSLayoutConstraint?

    private lazy var replyingToLabel: UILabel = {
        let view = UILabel()
        view.font = .subhead
        view.textColor = .text(.caption)
        return view
    }()

    private lazy var messageReplyingToLabel: UILabel = {
        let view = UILabel()
        view.font = .callout
        view.textColor = .text(.caption)
        return view
    }()

    private lazy var closeReplyingToButton: BaseButton = {
        let view = BaseButton()
        view.setImage(UIImage(systemName: "xmark"),for: .normal)
        view.tintColor = .text(.caption)
        return view
    }()

    private lazy var bottomView: BaseView = {
        let view = BaseView()
        view.layer.cornerRadius = 22
        return view
    }()
    private weak var bottomViewBottomConstraint: NSLayoutConstraint?

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        textView.layer.cornerRadius = 22
        return textView
    }()

    private lazy var sendButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "paperplane.fill", withConfiguration: configuration)?.withRenderingMode(.alwaysTemplate)
        let view = BaseButton()
        view.setImage(image, for: .normal)
        view.tintColor = .caption
        return view
    }()

    private var navigationBar: ChatRoomListNavigationBar? {
        navigationController?.navigationBar as? ChatRoomListNavigationBar
    }

    private let viewModel = ChatRoomViewModel()

    // MARK: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        navigationBar?.showChatRoomMessageButtons = true
    }

    // MARK: - Setups

    override func setupNavigation() {
        title = viewModel.details?.name

        setNavigationBarDefaultStyle()
    }

    override func setupLayout() {
        view.backgroundColor = .white

        bottomView.backgroundColor = .lightGray.withAlphaComponent(0.5)

        addSubviews([
            collectionView,
            replyingToView.addSubviews([
                replyingToLabel,
                closeReplyingToButton,
                messageReplyingToLabel
            ]),
            bottomView.addSubviews([
                textView,
                sendButton
            ])
        ])
    }

    override func setupConstraints() {
        collectionView.left == view.left
        collectionView.right == view.right
        collectionView.top == view.top + 8
        collectionView.bottom == bottomView.top - 5

        replyingToView.left == view.left
        replyingToView.right == view.right
        replyingToView.bottom == bottomView.top
        replyingToViewHeightConstraint = replyingToView.height == 0

        replyingToLabel.left == replyingToView.left + 20
        replyingToLabel.right == closeReplyingToButton.left
        replyingToLabel.top == replyingToView.top + 3
        replyingToLabel.height == 22

        messageReplyingToLabel.left == replyingToView.left + 20
        messageReplyingToLabel.right == closeReplyingToButton.left
        messageReplyingToLabel.bottom == replyingToView.bottom - 3
        messageReplyingToLabel.height == 22

        closeReplyingToButton.right == replyingToView.right
        closeReplyingToButton.top == replyingToView.top
        closeReplyingToButton.bottom == replyingToView.bottom
        closeReplyingToButton.width == 44

        bottomView.left == view.left
        bottomView.right == view.right
        bottomView.height == 180
        bottomViewBottomConstraint = bottomView.bottom == view.bottom

        textView.top == bottomView.top + 8
        textView.left == bottomView.left + 8
        textView.right == sendButton.left - 8
        textView.bottom == bottomView.bottom - (AppConstant.safeAreaInsets.bottom + 8)

        sendButton.right == bottomView.right - 8
        sendButton.height == 44
        sendButton.centerY == bottomView.centerY
    }

    override func setupBindings() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.apply(items)
            }
            .store(in: &cancellables)
    }


    override func setupActions() {
        sendButton.tapHandlerAsync = { [weak self] _ in
            guard let self, !textView.text.isEmpty else { return }

            await viewModel.sendMessage(textView.text)

            textView.text = ""
        }

        navigationBar?.moreTapHandlerAsync = { [weak self] _ in
            guard let self, let details = viewModel.details else { return }

            let isRemovedChatRoom = await ChatRoomDetailsViewController.show(on: self, using: details)
            if isRemovedChatRoom {
                navigationController?.popViewController(animated: true)
            }
        }

        tapRecognizer.tapHandler = { [weak self] _ in
            self?.textView.resignFirstResponder()
        }

        closeReplyingToButton.tapHandler = { [weak self] _ in
            guard let self else { return }
            replyingToViewHeightConstraint?.constant = 0
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }

        keyboardAppear = self

        Task { await viewModel.load() }
    }

    static func push(on parentViewController: UIViewController, using details: ChatInfo) {
        let viewController = Self()
        viewController.viewModel.details = details
        if let navigationController =  parentViewController.navigationController {
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    
}

extension ChatRoomViewController {
    private func getSectionLayout() -> NSCollectionLayoutSection {
        let unitSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(70))
        let item = NSCollectionLayoutItem(layoutSize: unitSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: unitSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)),
                elementKind: ChatRoomMessageHeaderCollectionReusableView.viewOfKind,
                alignment: .top
            )
        ]
        return section
    }
}
// MARK: - Set View Based on Data

extension ChatRoomViewController {
    private func apply(_ items: [Section: [Item]]) {
        guard !items.isEmpty else { return }

        var snapshot = Snapshot()
        snapshot.appendSections(items.keys.sorted(by: { $0.sortIndex < $1.sortIndex }))

        for (section, subitems) in items {
            snapshot.appendItems(subitems, toSection: section)
        }

        if let dataSource {
            dataSource.apply(snapshot, animatingDifferences: true)
        } else {
            dataSource = DataSource(
                collectionView: collectionView,
                cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
                    switch itemIdentifier {
                    case .messageItem(let info): self?.getMessageCell(at: indexPath, item: info)
                    }
                })

            dataSource?.supplementaryViewProvider = { [weak self] in
                switch $1 {
                case ChatRoomMessageHeaderCollectionReusableView.viewOfKind:
                    self?.getHeader(at: $2)
                default:
                    fatalError()
                }
            }

            if #available(iOS 15.0, *) {
                dataSource?.applySnapshotUsingReloadData(snapshot)
            } else {
                dataSource?.apply(snapshot)
            }
        }

        collectionView.scrollToBottom()

    }

    private func getHeader(at indexPath: IndexPath) -> ChatRoomMessageHeaderCollectionReusableView {
        let view = ChatRoomMessageHeaderCollectionReusableView.dequeueView(from: collectionView, for: indexPath)

        if let sectionIdentifer = dataSource?.snapshot().sectionIdentifiers[indexPath.section],
           case .main(let item, _) = sectionIdentifer {
            view.title = "\(item)"
        }
        return view
    }

    private func getMessageCell(at indexPath: IndexPath, item: ItemInfo) -> ChatRoomMessageCollectionViewCell {
        let cell = ChatRoomMessageCollectionViewCell.dequeueCell(from: collectionView, for: indexPath)
        cell.content = item.content
        cell.name = item.name
        cell.time = item.time
        cell.isCurrentUser = item.isCurrentUser
        cell.showOptionsHandler = { [weak self] content in
            guard let self, let contentSnapshot = content.snapshotView(afterScreenUpdates: true)else { return }
            switch await ChatRoomMessageOptionsViewController.show(
                on: self.navigationController!,
                with: contentSnapshot, and: item.isCurrentUser,
                at: content.convert(content.bounds.origin, to: self.view)
            ) {
            case .reply: showReplyingTo(name: "Replying to \(item.isCurrentUser ? "Yourself" : item.name)", message: item.content)
            case .edit: showEditingView(message: item.content)
            case .delete: break
            }
        }
        return cell
    }

    private func showReplyingTo(name: String, message: String) {
        replyingToLabel.text = name
        messageReplyingToLabel.text = message
        replyingToViewHeightConstraint?.constant = 44
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    private func showEditingView(message: String) {
        replyingToLabel.text = "Edit message"
        textView.text = message
        textView.becomeFirstResponder()
        replyingToViewHeightConstraint?.constant = 44
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ChatRoomViewController: ViewControllerKeyboardAppear {
    func willShowKeyboard(frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve) {


        bottomViewBottomConstraint?.constant =  -(frame.height - AppConstant.safeAreaInsets.bottom)
        UIView.animate(withDuration: duration, delay: 0, options: curve.animationOptions) { [weak self] in
            guard let self else { return }

            view.layoutIfNeeded()

            let bottomOffset = CGPoint(x: 0,
                                       y: collectionView.contentSize.height
                                       - collectionView.bounds.height
                                       + collectionView.contentInset.bottom)
            collectionView.setContentOffset(bottomOffset, animated: false)
        }
    }

    func willHideKeyboard(frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve) {
        bottomViewBottomConstraint?.constant = 0
        UIView.animate(withDuration: duration, delay: 0, options: curve.animationOptions) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

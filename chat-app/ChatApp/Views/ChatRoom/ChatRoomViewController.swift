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
        view.delegate = self
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 13, right: 0)

        ChatRoomMessageCollectionViewCell.registerCell(to: view)
        ChatRoomMessageHeaderCollectionReusableView.registerView(to: view)
        return view
    }()

    private lazy var loadMoreIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = false
        return view
    }()

    private lazy var tapRecognizer: BaseTapGestureRecognizer = {
        let recognizer = BaseTapGestureRecognizer(on: collectionView)
        return recognizer
    }()

    private lazy var isTypingView: BaseView = {
        let view = BaseView()
        view.alpha = 0
        view.backgroundColor = .mainBackground
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        return view
    }()

    private lazy var isTypingLabel: UILabel = {
        let view = UILabel()
        view.font = .captionSubtext.semibold()
        view.textColor = .subtext
        return view
    }()

    private lazy var replyingToView: BaseView = {
        let view = BaseView()
        view.backgroundColor = .mainBackground
        view.clipsToBounds = true
        return view
    }()
    private weak var replyingToViewHeightConstraint: NSLayoutConstraint?

    private lazy var replyingToLabel: UILabel = {
        let view = UILabel()
        view.font = .body.semibold()
        view.textColor = .subtext
        return view
    }()

    private lazy var messageReplyingToLabel: UILabel = {
        let view = UILabel()
        view.font = .caption
        view.textColor = .subtext
        return view
    }()

    private lazy var closeReplyingToButton: BaseButton = {
        let view = BaseButton()
        view.setImage(UIImage(systemName: "xmark"),for: .normal)
        view.tintColor = .main
        view.backgroundColor = .clear
        return view
    }()

    private lazy var bottomView: BaseView = {
        let view = BaseView()
        view.layer.cornerRadius = 22
        return view
    }()
    private weak var bottomViewHeightConstraint: NSLayoutConstraint?
    private weak var bottomViewBottomConstraint: NSLayoutConstraint?

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 13, left: 5, bottom: 13, right: 5)
        textView.font = .body
        textView.layer.cornerRadius = 22
        textView.clipsToBounds = true
        textView.backgroundColor = .mainBackground
        textView.delegate = self
        return textView
    }()

    private lazy var sendButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "paperplane.fill", withConfiguration: configuration)?.withRenderingMode(.alwaysTemplate)
        let view = BaseButton()
        view.setImage(image, for: .normal)
        view.tintColor = .main
        view.backgroundColor = .clear
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

        guard let details = viewModel.details else { return }
        navigationBar?.title = details.name
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationBar?.peopleCount = ""
    }

    // MARK: - Setups

    override func setupNavigation() {
        setNavigationBarDefaultStyle()
    }

    override func setupLayout() {
        view.backgroundColor = .white

        addSubviews([
            collectionView.addSubviews([
                loadMoreIndicator
            ]),
            isTypingView.addSubviews([
                isTypingLabel
            ]),
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
        collectionView.bottom == replyingToView.top - 5

        loadMoreIndicator.width == 40
        loadMoreIndicator.height == 40
        loadMoreIndicator.centerX == collectionView.centerX
        loadMoreIndicator.bottom == collectionView.top

        isTypingView.left == view.left
        isTypingView.bottom == bottomView.top

        isTypingLabel.left == isTypingView.left + 8
        isTypingLabel.right == isTypingView.right - 8
        isTypingLabel.top == isTypingView.top + 4
        isTypingLabel.bottom == isTypingView.bottom - 4

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
        bottomViewHeightConstraint = bottomView.height == 60
        bottomViewBottomConstraint = bottomView.bottom == view.bottomMargin

        textView.top == bottomView.top + 8
        textView.left == bottomView.left + 8
        textView.right == sendButton.left - 8
        textView.bottom == bottomView.bottom - 8

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
        viewModel.$typingString
            .receive(on: DispatchQueue.main)
            .sink { [weak self] typingString in
                self?.isTypingLabel.text = typingString
                UIView.animate(withDuration: 0.1) {
                    self?.isTypingView.alpha = typingString.isEmpty ? 0 : 1
                }
            }
            .store(in: &cancellables)
        viewModel.$peopleCountString
            .receive(on: DispatchQueue.main)
            .sink { [weak self] peopleCountString in
                self?.navigationBar?.peopleCount = peopleCountString
            }
            .store(in: &cancellables)
    }


    override func setupActions() {
        sendButton.tapHandlerAsync = { [weak self] _ in
            guard let self, !textView.text.isEmpty else { return }

            await viewModel.sendMessage(textView.text)
            viewModel.isLoaded = false
            textView.text = ""
            textViewDidChange(textView)
        }

        navigationBar?.moreTapHandlerAsync = { [weak self] _ in
            guard let self, let details = viewModel.details else { return }

            let (isRemovedChatRoom, newName) = await ChatRoomDetailsViewController.push(on: self, using: details)
            if isRemovedChatRoom {
                navigationController?.popToRootViewController(animated: true)
            } else if let newName {
                navigationBar?.title = newName
            }
        }

        tapRecognizer.tapHandler = { [weak self] _ in
            self?.textView.resignFirstResponder()
        }

        closeReplyingToButton.tapHandler = { [weak self] _ in
            self?.viewModel.isEditingMessageId = nil
            self?.viewModel.isReplyingMessageId = nil

            self?.removeReplyingOrEditingIndicator()
        }

        appWillResignActiveHandler = { _ in
            self.viewModel.setTyping(isTyping: false)
        }

        keyboardAppear = self

        Task { await viewModel.load() }
    }

    private func loadMore() {
        viewModel.isLoadingMore = true
        viewModel.loadMore()
    }

    private func removeReplyingOrEditingIndicator() {
        replyingToViewHeightConstraint?.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Navigation

extension ChatRoomViewController {
    static func push(on parentViewController: UIViewController, using details: ChatInfo) {
        let viewController = Self()
        viewController.viewModel.details = details
        if let navigationController =  parentViewController.navigationController {
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}

// MARK: - Collection Layout

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
        let currentOffset = collectionView.contentOffset.y
        let contentHeightBefore = collectionView.contentSize.height

        var snapshot = Snapshot()
        snapshot.appendSections(items.keys.sorted(by: { $0.sortIndex < $1.sortIndex }))

        for (section, subitems) in items {
            snapshot.appendItems(subitems, toSection: section)
        }

        if let dataSource {
            dataSource.apply(snapshot, animatingDifferences: false)
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

        guard !viewModel.isLoaded else {
            if viewModel.isLoadingMore {
                let contentHeightAfter = self.collectionView.contentSize.height
                let offsetChange = contentHeightAfter - contentHeightBefore
                self.collectionView.contentOffset = CGPoint(x: 0, y: currentOffset + offsetChange)
            }

            viewModel.isLoadingMore = false
            loadMoreIndicator.stopAnimating()
            return
        }

        viewModel.isLoadingMore = false
        loadMoreIndicator.stopAnimating()

        collectionView.scrollToBottom()
        removeReplyingOrEditingIndicator()

        Task { 
            await Task.sleep(seconds: 0.3)
            viewModel.isLoaded = true
        }
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
        cell.imageUrlString = item.imageUrlString
        cell.showOptionsHandler = { [weak self] content in
            guard let self, let contentSnapshot = content.snapshotView(afterScreenUpdates: true)else { return }
            switch await ChatRoomMessageOptionsViewController.show(
                on: self.navigationController!,
                with: contentSnapshot, and: item.isCurrentUser,
                at: content.convert(content.bounds.origin, to: self.view)
            ) {
            case .reply: showReplyingTo(name: "Replying to \(item.isCurrentUser ? "Yourself" : item.name)", message: item.content, messageId: item.id)
            case .edit: showEditingView(message: item.content, messageId: item.id)
            case .delete: viewModel.deleteMessage(item.id)
            case .none: break
            }
        }
        if let replyTo = item.replyTo, let replyToContent = replyTo.isReplyingToContent {
            cell.replyToContent = replyToContent
            cell.replyToName = "Replied to \(replyTo.isReplyingToName)"
        } else {
            cell.hideReplyTo()
        }
        return cell
    }

    private func showReplyingTo(name: String, message: String, messageId: Int) {
        viewModel.isReplyingMessageId = messageId

        replyingToLabel.text = name
        messageReplyingToLabel.text = message
        textView.becomeFirstResponder()

        replyingToViewHeightConstraint?.constant = 44
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    private func showEditingView(message: String, messageId: Int) {
        viewModel.isEditingMessageId = messageId

        replyingToLabel.text = "Edit message"
        messageReplyingToLabel.text = ""
        textView.becomeFirstResponder()
        textView.text = message
        textViewDidChange(textView)

        replyingToViewHeightConstraint?.constant = 44
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ChatRoomViewController: ViewControllerKeyboardAppear {
    func willShowKeyboard(frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve) {
        bottomViewBottomConstraint?.constant =  -(frame.height - AppConstant.safeAreaInsets.bottom)
        self.viewModel.setTyping(isTyping: true)
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
        self.viewModel.setTyping(isTyping: false)
        UIView.animate(withDuration: duration, delay: 0, options: curve.animationOptions) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

extension ChatRoomViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.viewModel.setTyping(isTyping: true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.viewModel.setTyping(isTyping: false)
    }

    func textViewDidChange(_ textView: UITextView) {
        self.viewModel.setTyping(isTyping: true)
        guard let bottomViewHeightConstraint else { return }
        let textViewHeight = getTextViewContentHeight()
        if textViewHeight < 117 {
            bottomViewHeightConstraint.constant = textViewHeight
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        }
    }

    func getTextViewContentHeight() -> CGFloat {
        guard textView.text != nil else { return 0 }

        let sizeThatFits = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude))

        let contentHeight = sizeThatFits.height + textView.textContainerInset.top

        return contentHeight
    }
}

extension ChatRoomViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -130 && !viewModel.isLoadingMore && viewModel.isLoaded {
            viewModel.shouldLoadMore = true
            loadMoreIndicator.startAnimating()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard viewModel.shouldLoadMore  else { return }
    
        viewModel.shouldLoadMore = false
        loadMore()
    }
}

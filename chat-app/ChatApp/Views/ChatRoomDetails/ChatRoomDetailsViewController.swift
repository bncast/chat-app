//
//  ChatRoomDetailsViewController.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/21/24.
//

import UIKit
import SuperEasyLayout
import SwipeCellKit

class ChatRoomDetailsViewController: BaseViewController {
    private lazy var layout: UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { [weak self] index, _ in
            guard let self, let sections = dataSource?.snapshot().sectionIdentifiers else { fatalError() }
            return getSectionLayout()
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundView = nil
        view.backgroundColor = .white

        MemberHeaderCollectionReusableView.registerView(to: view)
        MemberWithStatusCollectionViewCell.registerCell(to: view)
        return view
    }()

    private lazy var inviteButton: BaseButton = {
        let view = BaseButton()
        view.text = "INVITE"
        view.colorStyle = .active
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var deleteRoomButton: BaseButton = {
        let view = BaseButton()
        view.text = "DELETE ROOM"
        view.colorStyle = .active
        view.layer.cornerRadius = 8
        return view
    }()

    private var navigationBar: ChatRoomListNavigationBar? {
        navigationController?.navigationBar as? ChatRoomListNavigationBar
    }
    
    private typealias ItemInfo = ChatRoomDetailsViewModel.ItemInfo
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, ItemInfo>
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, ItemInfo>
    private var dataSource: DataSource?

    private let viewModel = ChatRoomDetailsViewModel()
    private var continuation: CheckedContinuation<(Bool, String?), Never>?

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar?.showCloseButtonOnly = true
        viewModel.load()
    }

    // MARK: - Setups

    override func setupNavigation() {
        setNavigationBarDefaultStyle()
        navigationBar?.title = "Members"
    }

    override func setupLayout() {
        view.backgroundColor = .white

        addSubviews([
            collectionView,
            inviteButton,
            deleteRoomButton
        ])
    }
    var constraintBottomToButton: NSLayoutConstraint?
    var constraintBottomToParent: NSLayoutConstraint?

    override func setupConstraints() {
        collectionView.left == view.left
        collectionView.right == view.right
        collectionView.top == view.top + 20
        constraintBottomToButton = collectionView.bottom == inviteButton.top - 20
        constraintBottomToParent = collectionView.bottom == view.bottomMargin - 20

        constraintBottomToParent?.isActive = false

        inviteButton.left == view.left + 20
        inviteButton.right == view.right - 20
        inviteButton.height == 44
        inviteButton.bottom == view.bottomMargin - 84

        deleteRoomButton.left == view.left + 20
        deleteRoomButton.right == view.right - 20
        deleteRoomButton.height == 44
        deleteRoomButton.bottom == view.bottomMargin - 20
    }

    override func setupBindings() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.apply(items)
            }
            .store(in: &cancellables)
        viewModel.$isAdmin
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAdmin in
                self?.deleteRoomButton.isHidden = !isAdmin
                self?.inviteButton.isHidden = !isAdmin
                self?.constraintBottomToButton?.isActive = isAdmin
                self?.constraintBottomToParent?.isActive = !isAdmin
            }
            .store(in: &cancellables)
    }

    override func setupActions() {
        navigationBar?.closeTapHandler = { [weak self] _ in
            self?.dismiss(animated: true) { [weak self] in
                self?.continuation?.resume(returning: (false, self?.viewModel.updatedName))
            }
        }

        inviteButton.tapHandlerAsync = { [weak self] _ in
            guard let self, let roomId = viewModel.details?.roomId else { return }
            
            UserListViewController.show(on: self, roomId: roomId)
        }

        deleteRoomButton.tapHandlerAsync = { [weak self] _ in
            guard let self,
                  let chatName = viewModel.details?.name,
                  let isDeleteChatRoom = await showChatRoomDeleteAlert(in: self, chatName: chatName),
                  let roomUserId = viewModel.details?.currentRoomUserId,
                  isDeleteChatRoom
            else { return }

            await IndicatorController.shared.show()
            do {
                try await viewModel.removeChatRoom(roomUserId: roomUserId)
                await IndicatorController.shared.dismiss()
                dismiss(animated: true)
                continuation?.resume(returning: (isDeleteChatRoom, nil))
            } catch {
                print("[ChatRoomDetailsViewController] Error! \(error as! NetworkError)")
                await IndicatorController.shared.dismiss()
                continuation?.resume(returning: (false, nil))
            }
        }
    }

    @MainActor
    private func showChatRoomEditNameAlert(in viewController: UIViewController, currentName: String) async -> String? {
        return await AsyncInputAlertController<String>(
            title: "Change name for \(currentName)",
            message: "Enter new chat room name.",
            name: currentName
        )
        .addButton(title: "OK")
        .register(in: viewController)
    }

    @MainActor
    private func showChatRoomDeleteAlert(in viewController: UIViewController, chatName: String) async -> Bool? {
        return await AsyncAlertController<Bool>(
            title: "Delete confirmation",
            message: "Are you sure you want to delete the chat room \(chatName) and all it's messages?"
        )
        .addButton(title: "Yes, I want to delete this chat room", style: .destructive, returnValue: true)
        .addButton(title: "Cancel", returnValue: false)
        .register(in: viewController)
    }
}

// MARK: - Navigation

extension ChatRoomDetailsViewController {
    static func show(on parentViewController: UIViewController, using details: ChatInfo) async -> (Bool, String?) {
        return await withCheckedContinuation { continuation in
            let viewController = Self()
            viewController.viewModel.details = details
            viewController.continuation = continuation

            let navigationController = UINavigationController(navigationBarClass: ChatRoomListNavigationBar.self,
                                                              toolbarClass: nil)
            navigationController.modalPresentationStyle = .overFullScreen
            navigationController.transitioningDelegate = viewController.fadeInAnimator
            navigationController.viewControllers = [viewController]

            parentViewController.present(navigationController, animated: true)
        }
    }
}

// MARK: - Collection Layout

extension ChatRoomDetailsViewController {
    private func getSectionLayout() -> NSCollectionLayoutSection {
        let unitSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(84))
        let item = NSCollectionLayoutItem(layoutSize: unitSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: unitSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(180)),
                elementKind: MemberHeaderCollectionReusableView.viewOfKind,
                alignment: .top
            )
        ]
        return section
    }
}

// MARK: - Set View Based on Data

extension ChatRoomDetailsViewController {
    private func apply(_ items: [ItemInfo]) {
        guard !items.isEmpty else { return }

        var snapshot = Snapshot()
        snapshot.appendSections([0])

        snapshot.appendItems(items)

        if let dataSource {
            dataSource.apply(snapshot, animatingDifferences: true)
        } else {
            dataSource = DataSource(
                collectionView: collectionView,
                cellProvider: { [weak self] collectionView, indexPath, info in
                    self?.getMemberCell(at: indexPath, item: info)
                })
            dataSource?.supplementaryViewProvider = { [weak self] in
                switch $1 {
                case MemberHeaderCollectionReusableView.viewOfKind:
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
    }

    private func reloadData() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])

        snapshot.appendItems(viewModel.items)

        dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, info in
                self?.getMemberCell(at: indexPath, item: info)
            })
        dataSource?.supplementaryViewProvider = { [weak self] in
            switch $1 {
            case MemberHeaderCollectionReusableView.viewOfKind:
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

    private func getHeader(at indexPath: IndexPath) -> MemberHeaderCollectionReusableView {
        let view = MemberHeaderCollectionReusableView.dequeueView(from: collectionView, for: indexPath)

        view.title = viewModel.details?.name
        view.imageUrlString = viewModel.getRoomImageUrlString()
        view.isAdmin = viewModel.isAdmin
        view.editHandler = { [weak self] currentName in
            guard let self, viewModel.isAdmin,
                  let roomUserId = self.viewModel.details?.currentRoomUserId,
                  let currentName,
                  let updatedName = await self.showChatRoomEditNameAlert(in: self, currentName: currentName)
            else { return nil }

            do {
                await IndicatorController.shared.show()
                try await viewModel.updateChatRoomNameInServer(name: updatedName, roomUserId: roomUserId)
                await IndicatorController.shared.dismiss()

                viewModel.updatedName = updatedName
                return updatedName
            } catch {
                print("[ChatRoomDetailsViewController] Error in ChatRoom change name! \(error as! NetworkError)")
                await IndicatorController.shared.dismiss()
                return nil
            }
        }

        return view
    }

    private func getMemberCell(at indexPath: IndexPath, item: ItemInfo) -> MemberWithStatusCollectionViewCell {
        let cell = MemberWithStatusCollectionViewCell.dequeueCell(from: collectionView, for: indexPath)
        cell.delegate = self
        cell.roomUserId = item.id
        cell.name = item.name
        cell.isAdmin = item.isAdmin
        cell.currentUserIsAdmin = viewModel.isAdmin
        cell.setIsAdminInServerHandler = { [weak self] isAdmin in
            guard let self else { return !isAdmin }
            do {
                await IndicatorController.shared.show()
                try await viewModel.setIsAdminInServer(isAdmin: isAdmin, roomUserId: item.id)
                await IndicatorController.shared.dismiss()
                viewModel.updateIsAdmin(isAdmin: isAdmin, roomUserId: item.id)
                return isAdmin
            } catch {
                print("[ChatRoomDetailsViewController] Error in setting admin! \(error as! NetworkError)")
                await IndicatorController.shared.dismiss()
                return !isAdmin
            }
        }

        return cell
    }
}

extension ChatRoomDetailsViewController: SwipeCollectionViewCellDelegate {
    func collectionView(
        _ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath,
        for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else { return nil }

        let item = viewModel.items[indexPath.row]
        let deleteAction = SwipeAction(
            style: .destructive, title: "Delete"
        ) { [weak self] _, indexPath in
            Task {
                await IndicatorController.shared.show()
                if await self?.viewModel.removeUserFromChatRoom(roomUserId: item.id) == true {
                    self?.viewModel.items.remove(at: indexPath.row)
                }
                await IndicatorController.shared.dismiss()
            }
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.font = .caption
        deleteAction.backgroundColor = .systemRed
        return [deleteAction]
    }

    func collectionView(
        _: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for: SwipeActionsOrientation
    ) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        options.transitionStyle = .border
        options.buttonSpacing = 4
        return options
    }
}

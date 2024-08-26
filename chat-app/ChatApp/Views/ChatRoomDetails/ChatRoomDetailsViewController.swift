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
    private lazy var closeButton: BaseButton = {
        let view = BaseButton()
        view.setImage(UIImage(systemName: "xmark"),for: .normal)
        view.tintColor = .text(.caption)
        return view
    }()

    private lazy var layout: UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { [weak self] index, _ in
            guard let self, let sections = dataSource?.snapshot().sectionIdentifiers else { fatalError() }
            return getSectionLayout()
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundView = nil
        view.backgroundColor = .background(.main)

        MemberHeaderCollectionReusableView.registerView(to: view)
        MemberWithStatusCollectionViewCell.registerCell(to: view)
        return view
    }()

    private lazy var inviteButton: BaseButton = {
        let view = BaseButton()
        view.backgroundColor = .button(.active)
        view.setTitle("INVITE", for: .normal)
        view.titleLabel?.textColor = .text(.caption)
        view.titleLabel?.font = .title3
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var deleteRoomButton: BaseButton = {
        let view = BaseButton()
        view.backgroundColor = .button(.active)
        view.setTitle("DELETE ROOM", for: .normal)
        view.titleLabel?.textColor = .text(.caption)
        view.titleLabel?.font = .title3
        view.layer.cornerRadius = 8
        return view
    }()

    private typealias ItemInfo = ChatRoomDetailsViewModel.ItemInfo
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, ItemInfo>
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, ItemInfo>
    private var dataSource: DataSource?

    private let viewModel = ChatRoomDetailsViewModel()
    private var continuation: CheckedContinuation<Bool, Never>?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.load()
    }

    override func setupLayout() {
        view.backgroundColor = .background(.main)

        addSubviews([
            closeButton,
            collectionView,
            inviteButton,
            deleteRoomButton
        ])
    }

    override func setupConstraints() {
        closeButton.right == view.right - 20
        closeButton.top == view.topMargin
        closeButton.width == 44
        closeButton.height == 44

        collectionView.left == view.left
        collectionView.right == view.right
        collectionView.top == closeButton.bottom + 20
        collectionView.bottom == inviteButton.top - 20

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
    }

    override func setupActions() {
        closeButton.tapHandler = { [weak self] _ in
            self?.dismiss(animated: true)
        }

        inviteButton.tapHandler = { _ in
            print("[ChatRoomDetailsViewController] inviteButton.tapHandler")
        }
        deleteRoomButton.tapHandlerAsync = { [weak self] _ in
            guard let self else { return }
            guard let isDeleteChatRoom = await showChatRoomDeleteAlert(in: self), isDeleteChatRoom == true else { return }

            await IndicatorController.shared.show()
            do {
                try await viewModel.removeChatRoom(roomUserId: 1234)
                await IndicatorController.shared.dismiss()
                dismiss(animated: true)
                continuation?.resume(returning: isDeleteChatRoom)
            } catch {
                print("[ChatRoomDetailsViewController] Error! \(error as! NetworkError)")
                await IndicatorController.shared.dismiss()
                continuation?.resume(returning: false)
            }
        }
    }

    @MainActor
    private func showChatRoomEditNameAlert(in viewController: UIViewController, currentName: String) async -> String? {
        return await AsyncInputAlertController<String>(
            title: "CHAT ROOM",
            message: "Edit chatroom name.",
            name: currentName
        )
        .addButton(title: "Ok")
        .register(in: viewController)
    }

    @MainActor
    private func showChatRoomDeleteAlert(in viewController: UIViewController) async -> Bool? {
        return await AsyncAlertController<Bool>(
            title: "CHAT ROOM",
            message: "Delete this chat room?"
        )
        .addButton(title: "Ok", returnValue: true)
        .addButton(title: "Cancel", returnValue: false)
        .register(in: viewController)
    }

    static func show(on parentViewController: UIViewController) async -> Bool {
        return await withCheckedContinuation { continuation in
            let chatRoomDetailsViewController = Self()
            chatRoomDetailsViewController.continuation = continuation
            chatRoomDetailsViewController.modalPresentationStyle = .overFullScreen
            chatRoomDetailsViewController.transitioningDelegate = chatRoomDetailsViewController.fadeInAnimator
            parentViewController.present(chatRoomDetailsViewController, animated: true)
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
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(228)),
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

        view.title = "Chat Room"
        view.editHandler = { [weak self] currentName in
            guard let self, let updatedChatroomName = await self.showChatRoomEditNameAlert(in: self, currentName: currentName) else { return "" }
            
            return updatedChatroomName
        }
        view.editNameInServerHandler = { [weak self] updatedTitle in
            guard let self else { return "" }

            do {
                await IndicatorController.shared.show()
                try await viewModel.updateChatRoomNameInServer(name: updatedTitle)
                await IndicatorController.shared.dismiss()
                return updatedTitle
            } catch {
                print("[ChatRoomDetailsViewController] Error in ChatRoom change name! \(error as! NetworkError)")
                await IndicatorController.shared.dismiss()
                return ""
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
        cell.backgroundColor = indexPath.row % 2 == 0 ? .background(.mainLight) : .background(.main)
        
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
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .background(.mainLight)
        }

        return cell
    }
}

extension ChatRoomDetailsViewController: SwipeCollectionViewCellDelegate {
    func collectionView(
        _ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath,
        for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(
            style: .destructive, title: "Delete"
        ) { [weak self] _, indexPath in
            self?.viewModel.items.remove(at: indexPath.row)
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

//
//  InvitationListViewController.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/26/24.
//

import UIKit
import SuperEasyLayout

class InvitationListViewController: BaseViewController {
    private lazy var layout: UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { [weak self] index, _ in
            guard let self, let sections = dataSource?.snapshot().sectionIdentifiers else { fatalError() }

            switch sections[index] {
            case .list: return getListSectionLayout()
            case .whole: return getWholeSectionLayout()
            }
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundView = nil
        view.backgroundColor = .white

        NoDataCollectionViewCell.registerCell(to: view)
        InvitationCollectionViewCell.registerCell(to: view)
        return view
    }()

    private var navigationBar: ChatRoomListNavigationBar? {
        navigationController?.navigationBar as? ChatRoomListNavigationBar
    }

    private typealias Section = InvitationListViewModel.Section
    private typealias Item = InvitationListViewModel.Item
    private typealias ItemInfo = InvitationListViewModel.ItemInfo
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    private var dataSource: DataSource?

    private let viewModel = InvitationListViewModel()
    var continuation: CheckedContinuation<ChatInfo?, Never>?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            do {
                await IndicatorController.shared.show()
                try await viewModel.load()
                await IndicatorController.shared.dismiss()
            } catch {
                await IndicatorController.shared.dismiss()
                print("[InvitationListViewController] Error: \(error)")
            }
        }
    }

    // MARK: - Setups
    
    override func setupLayout() {
        view.backgroundColor = .main

        addSubviews([
            collectionView
        ])
    }

    override func setupNavigation() {
        setNavigationBarDefaultStyle()

        navigationBar?.title = "Invitations"
        navigationBar?.hideAllButton = true
    }

    override func setupConstraints() {
        collectionView.left == view.left
        collectionView.right == view.right
        collectionView.top == view.topMargin
        collectionView.bottom == view.bottom
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
    }
}

// MARK: - Navigation

extension InvitationListViewController {
    static func push(on parentViewController: UIViewController) async -> ChatInfo? {
        await withCheckedContinuation { continuation in
            let viewController = Self()
            viewController.continuation = continuation

            if let navigationController =  parentViewController.navigationController {
                navigationController.pushViewController(viewController, animated: true)
            }
        }
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        continuation?.resume(returning: nil)
    }
}

// MARK: - Collection Layout

extension InvitationListViewController {
    private func getListSectionLayout() -> NSCollectionLayoutSection {
        let unitSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(84))
        let item = NSCollectionLayoutItem(layoutSize: unitSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: unitSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }

    private func getWholeSectionLayout() -> NSCollectionLayoutSection {
        let unitSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: unitSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: unitSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
}

// MARK: - Set View Based on Data

extension InvitationListViewController {
    private func apply(_ items: [Section: [Item]]) {
        guard !items.isEmpty else { return }

        var snapshot = Snapshot()
        snapshot.appendSections(items.keys.sorted())

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
                    case .invitation(let info): self?.getInvitationCell(at: indexPath, item: info)
                    case .noData: self?.getNoDataCell(at: indexPath)
                    }
                })

            if #available(iOS 15.0, *) {
                dataSource?.applySnapshotUsingReloadData(snapshot)
            } else {
                dataSource?.apply(snapshot)
            }
        }
    }

    private func getInvitationCell(at indexPath: IndexPath, item: ItemInfo) -> InvitationCollectionViewCell {
        let cell = InvitationCollectionViewCell.dequeueCell(from: collectionView, for: indexPath)
        cell.chatRoomName = item.chatRoomName
        cell.isInvited = item.isInvited
        cell.joinTapHandlerAsync = { [weak self] _ in
            do {
                await IndicatorController.shared.show()
                let chatInfo = try await self?.viewModel.join(roomId: item.roomId, invitationId: item.id)
                await IndicatorController.shared.dismiss()

                self?.continuation?.resume(returning: chatInfo)
                self?.navigationController?.popViewController(animated: true)
            } catch {
                print("[UserListViewController] Error! \(error as! NetworkError)")
                await IndicatorController.shared.dismiss()
            }
        }

        return cell
    }

    private func getNoDataCell(at indexPath: IndexPath) -> NoDataCollectionViewCell {
        NoDataCollectionViewCell.dequeueCell(from: collectionView, for: indexPath)
    }
}

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
            return getSectionLayout()
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundView = nil
        view.backgroundColor = .white

        InvitationCollectionViewCell.registerCell(to: view)
        return view
    }()

    private var navigationBar: ChatRoomListNavigationBar? {
        navigationController?.navigationBar as? ChatRoomListNavigationBar
    }

    private typealias ItemInfo = InvitationListViewModel.ItemInfo
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, ItemInfo>
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, ItemInfo>
    private var dataSource: DataSource?

    private let viewModel = InvitationListViewModel()

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
        navigationBar?.showInvitationListButtons = true
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
        navigationBar?.closeTapHandler = { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - Navigation

extension InvitationListViewController {
    static func show(on parentViewController: UIViewController) {
        let viewController = Self()

        let navController = UINavigationController(navigationBarClass: ChatRoomListNavigationBar.self,
                                                   toolbarClass: nil)
        navController.viewControllers = [viewController]
        navController.modalPresentationStyle = .overFullScreen
        navController.transitioningDelegate = viewController.fadeInAnimator

        parentViewController.present(navController, animated: true)
    }
}

// MARK: - Collection Layout

extension InvitationListViewController {
    private func getSectionLayout() -> NSCollectionLayoutSection {
        let unitSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(84))
        let item = NSCollectionLayoutItem(layoutSize: unitSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: unitSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
}

// MARK: - Set View Based on Data

extension InvitationListViewController {
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
                    self?.getInvitationCell(at: indexPath, item: info)
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
        cell.backgroundColor = indexPath.row % 2 == 0 ? .background(.mainLight) : .background(.main)
        
        cell.joinTapHandlerAsync = { [weak self] _ in
            guard let chatInfo = await self?.viewModel.join(roomId: item.id) else { return }

            self?.dismiss(animated: true) //TODO: Redirect to chat room
        }

        return cell
    }
}

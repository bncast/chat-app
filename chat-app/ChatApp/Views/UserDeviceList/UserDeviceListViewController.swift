//
//  UserDeviceListViewController.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/11/24.
//

import UIKit
import SuperEasyLayout

class UserDeviceListViewController: BaseViewController {
    private typealias Section = UserDeviceListViewModel.Section
    private typealias Item = UserDeviceListViewModel.ItemInfo
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    private var dataSource: DataSource?

    private lazy var layout: UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { [weak self] index, _ in
            self?.getSectionLayout()
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundView = nil
        view.backgroundColor = .white

        UserDeviceCollectionViewCell.registerCell(to: view)
        return view
    }()

    private var navigationBar: ChatRoomListNavigationBar? {
        navigationController?.navigationBar as? ChatRoomListNavigationBar
    }

    private let viewModel = UserDeviceListViewModel()

    // MARK: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        navigationBar?.hideAllButton = true
        navigationBar?.title = "Devices"
    }

    // MARK: - Setups

    override func setupNavigation() {
        setNavigationBarDefaultStyle()
    }

    override func setupLayout() {
        view.backgroundColor = .main

        addSubviews([
            collectionView
        ])
    }

    override func setupConstraints() {
        collectionView.left == view.left
        collectionView.right == view.right
        collectionView.top == view.top
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

    static func push(on parentViewController: UIViewController) {
        let viewController = Self()
        if let navigationController =  parentViewController.navigationController {
            viewController.viewModel.load()
            navigationController.pushViewController(viewController, animated: true)
        }
    }}

// MARK: - Collection Layout

extension UserDeviceListViewController {
    private func getSectionLayout() -> NSCollectionLayoutSection {
        let unitSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1), heightDimension: .absolute(60)
        )
        let item = NSCollectionLayoutItem(layoutSize: unitSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: unitSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
}

// MARK: - Set View Based on Data

extension UserDeviceListViewController {
    private func apply(_ items: [Section: [Item]]) {
        guard !items.isEmpty else { return }

        var snapshot = Snapshot()
        snapshot.appendSections(items.keys.toArray)

        for (section, subitems) in items {
            snapshot.appendItems(subitems, toSection: section)
        }

        if let dataSource {
            dataSource.apply(snapshot, animatingDifferences: true)
        } else {
            dataSource = DataSource(
                collectionView: collectionView,
                cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
                    self?.getCell(at: indexPath, item: itemIdentifier)
                })
            if #available(iOS 15.0, *) {
                dataSource?.applySnapshotUsingReloadData(snapshot)
            } else {
                dataSource?.apply(snapshot)
            }
        }
    }

    private func getCell(at indexPath: IndexPath, item: Item) -> UserDeviceCollectionViewCell {
        let cell = UserDeviceCollectionViewCell.dequeueCell(from: collectionView, for: indexPath)
        cell.title = item.name
        cell.isFirst = indexPath.row == 0
        cell.tapHandlerAsync = { [weak self] _ in
            // TODO:
        }
        return cell
    }
}

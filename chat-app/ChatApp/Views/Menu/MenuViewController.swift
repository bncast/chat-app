//
//  MenuViewController.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/10/24.
//

import UIKit
import SuperEasyLayout

class MenuViewController: BaseViewController {
    private typealias Section = MenuViewModel.Section
    private typealias Item = MenuViewModel.Item
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

        MenuCollectionViewCell.registerCell(to: view)
        return view
    }()

    private var navigationBar: ChatRoomListNavigationBar? {
        navigationController?.navigationBar as? ChatRoomListNavigationBar
    }

    private let viewModel = MenuViewModel()

    // MARK: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        navigationBar?.hideAllButton = true
        navigationBar?.title = "Menu"
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

    override func setupActions() {
        viewModel.load()
    }

    func showProfile() async {
        await ProfileViewController.show(on: self)
    }

    func showChangePassword() async {
        await PasswordViewController.show(on: self)
    }

    func logout() async {
        do {
            await IndicatorController.shared.show()
            try await viewModel.logout()
            await IndicatorController.shared.dismiss()
            redirectToLogin()
        } catch {

        }
    }

    func redirectToLogin() {
        guard let navigationController = self.navigationController else { return }

        navigationController.dismiss(animated: true)
    }

    static func push(on parentViewController: UIViewController) {
        if let navigationController =  parentViewController.navigationController {
            navigationController.pushViewController(Self(), animated: true)
        }
    }
}

// MARK: - Collection Layout

extension MenuViewController {
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

extension MenuViewController {
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

    private func getCell(at indexPath: IndexPath, item: Item) -> MenuCollectionViewCell {
        let cell = MenuCollectionViewCell.dequeueCell(from: collectionView, for: indexPath)
        cell.title = item.rawValue
        cell.isFirst = item.isFirst
        cell.tapHandlerAsync = { [weak self] _ in
            switch item {
            case .profile: await self?.showProfile()
            case .devices: break
            case .password: await self?.showChangePassword()
            case .logout: await self?.logout()
            }
        }
        return cell
    }
}

//
//  ServerListViewController.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 9/9/24.
//

import UIKit
import SuperEasyLayout
import SwipeCellKit

class ServerListViewController: BaseViewController {
    struct ServerInfo: Codable {
        var name: String? = "Default"
        var address: String?
        var port: String?

        func empty() -> ServerInfo {
            return ServerInfo(name: "", address: "", port: "")
        }

        func isEqual(to info: ServerInfo) -> Bool {
            info.address == self.address && info.port == self.port
        }
    }

    private lazy var layout: UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { [weak self] index, _ in
            guard let self, let sections = dataSource?.snapshot().sectionIdentifiers else { fatalError() }
            return getListSectionLayout()
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundView = nil
        view.backgroundColor = .white

        ServerListCollectionViewCell.registerCell(to: view)
        return view
    }()

    private lazy var addServerButton: BaseButton = {
        let view = BaseButton()
        view.text = "ADD SERVER"
        view.colorStyle = .active
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var scanQRButton: BaseButton = {
        let view = BaseButton()
        view.setImage(UIImage(systemName: "qrcode"), for: .normal)
        view.colorStyle = .active
        view.layer.cornerRadius = 8
        return view
    }()

    private var navigationBar: ChatRoomListNavigationBar? {
        navigationController?.navigationBar as? ChatRoomListNavigationBar
    }

    private typealias ConnectionStatus = ServerListViewModel.ConnectionStatus
    private typealias ItemInfo = ServerListViewModel.ItemInfo
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, ItemInfo>
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, ItemInfo>
    private var dataSource: DataSource?

    private let viewModel = ServerListViewModel()

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
                print("[ServerListViewController] Error: \(error)")
            }
        }
    }

    // MARK: - Setups

    override func setupLayout() {
        view.backgroundColor = .white

        addSubviews([
            collectionView,
            addServerButton,
            scanQRButton
        ])
    }

    override func setupNavigation() {
        setNavigationBarDefaultStyle()

        navigationBar?.title = "Server List"
        navigationBar?.showServerListButton = true
    }

    override func setupConstraints() {
        collectionView.left == view.left
        collectionView.right == view.right
        collectionView.top == view.top + 20
        collectionView.bottom == addServerButton.top - 20

        addServerButton.left == view.left + 20
        addServerButton.right == scanQRButton.left - 8
        addServerButton.height == 44
        addServerButton.bottom == view.bottomMargin - 20

        scanQRButton.right == view.right - 20
        scanQRButton.top == addServerButton.top
        scanQRButton.width == 44
        scanQRButton.height == 44
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

        addServerButton.tapHandlerAsync = { [weak self] _ in
            guard let self, let info = await showAddEditServerAlert(in: self)else { return }

            var infoCopy = info
            while (viewModel.checkInfoIncomplete(info: infoCopy)) {
                guard let info = await showAddEditServerAlert(in: self, info: infoCopy) else { return }

                infoCopy = info
            }
            await viewModel.addServer(info: infoCopy)
        }

        scanQRButton.tapHandlerAsync = { [weak self] _ in
            guard let self, let qrString = await QRScannerViewController.show(on: self) else { return }

            guard let url = URL(string: qrString),
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  let queryItems = components.queryItems,
                  let q0Value = queryItems[0].value,
                  let q1Value = queryItems[1].value,
                  let q2Value = queryItems[2].value
            else { return }

            let serverInfo = ServerInfo(name: q0Value, address: q1Value, port: q2Value)
            let foundDuplicate = viewModel.checkInfoHasDuplicate(serverInfo)
            guard let info = await showAddEditServerAlert(in: self, name: foundDuplicate ? "Edit": "Add", info: serverInfo) else { return }

            var infoCopy = info
            while (viewModel.checkInfoIncomplete(info: infoCopy)) {
                guard let info = await showAddEditServerAlert(in: self, name: foundDuplicate ? "Edit": "Add", info: infoCopy) else { return }

                infoCopy = info
            }
            if !foundDuplicate {
                await viewModel.addServer(info: infoCopy)
            } else {
                guard let existingItem = (viewModel.items.first { existingInfo in
                    existingInfo.ipAddress == serverInfo.address && existingInfo.port == serverInfo.port
                }),
                      let name = infoCopy.name,
                      let address = infoCopy.address,
                      let port = infoCopy.port
                else { return }

                await viewModel.updateServer(info: ItemInfo(
                    id: existingItem.id, name: name, ipAddress: address, port: port, status: existingItem.status
                ) , infoToReplace: existingItem)
            }
        }
    }
}

// MARK: - Collection Layout

extension ServerListViewController {
    private func getListSectionLayout() -> NSCollectionLayoutSection {
        let unitSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(84))
        let item = NSCollectionLayoutItem(layoutSize: unitSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: unitSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
}

// MARK: - Navigation

extension ServerListViewController {
    static func show(on parentViewController: UIViewController, _ serverInfo: ServerInfo? = nil) {
        let navController = UINavigationController(navigationBarClass: ChatRoomListNavigationBar.self,
                                                   toolbarClass: nil)
        let viewController = Self()

        navController.viewControllers = [viewController]
        navController.modalPresentationStyle = .overFullScreen
        navController.transitioningDelegate = viewController.fadeInAnimator

        parentViewController.present(navController, animated: true) {
            guard let serverInfo else { return }

            Task {
                let foundDuplicate = viewController.viewModel.checkInfoHasDuplicate(serverInfo)
                guard let info = await viewController.showAddEditServerAlert(in: viewController, name: foundDuplicate ? "Edit": "Add", info: serverInfo) else { return }

                var infoCopy = info
                while (viewController.viewModel.checkInfoIncomplete(info: infoCopy)) {
                    guard let info = await viewController.showAddEditServerAlert(in: viewController, name: foundDuplicate ? "Edit": "Add", info: infoCopy) else { return }

                    infoCopy = info
                }
                if !foundDuplicate {
                    await viewController.viewModel.addServer(info: infoCopy)
                } else {
                    guard let existingItem = (viewController.viewModel.items.first { existingInfo in
                        existingInfo.ipAddress == serverInfo.address && existingInfo.port == serverInfo.port
                    }),
                    let name = infoCopy.name,
                    let address = infoCopy.address,
                    let port = infoCopy.port
                    else { return }

                    await viewController.viewModel.updateServer(info: ItemInfo(
                        id: existingItem.id, name: name, ipAddress: address, port: port, status: existingItem.status
                    ) , infoToReplace: existingItem)
                }
            }
        }
    }
}

// MARK: - Set View Based on Data

extension ServerListViewController {
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
                    self?.getServerCell(at: indexPath, item: info)
                })
            if #available(iOS 15.0, *) {
                dataSource?.applySnapshotUsingReloadData(snapshot)
            } else {
                dataSource?.apply(snapshot)
            }
        }
    }
    private func getServerCell(at indexPath: IndexPath, item: ItemInfo) -> ServerListCollectionViewCell {
        let cell = ServerListCollectionViewCell.dequeueCell(from: collectionView, for: indexPath)
        cell.delegate = self
        cell.name = item.name
        cell.hostName = item.ipAddress + ":" + item.port
        cell.connectionStatus = item.status
        cell.qrTapHandlerAsync = { [weak self] in
            guard let self else { return }
            await QRDisplayViewController.show(on: self, with:
                                                ServerInfo(name: item.name, address: item.ipAddress, port: item.port))
        }
        cell.tapHandlerAsync = { [weak self] _ in
            await IndicatorController.shared.show()
            await self?.viewModel.connectToServer(item)
            await IndicatorController.shared.dismiss()
        }
        return cell
    }
}

extension ServerListViewController: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let item = viewModel.items[indexPath.row]
        let deleteAction = SwipeAction(
            style: .destructive, title: "Delete"
        ) { [weak self] action, indexPath in
            Task { [weak self] in
                guard let self else { return }
                if item.status != .connected {
                    viewModel.deleteServer(index: indexPath)
                } else {
                    await AsyncAlertController<Void>(
                        title: "Cannot delete connected server",
                        message: "Please disconnect server before removing"
                    )
                    .addButton(title: "OK", returnValue: Void())
                    .register(in: self)
                    action.fulfill(with: .reset)
                }
            }
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.font = .caption
        deleteAction.backgroundColor = .systemRed
        let editAction = SwipeAction(
            style: .default, title: "Edit"
        ) { [weak self] _, indexPath in
            Task { [weak self] in
                guard let self, let info = await showAddEditServerAlert(
                    in: self, name: "Edit", info: ServerInfo(
                        name: item.name, address: item.ipAddress, port: item.port
                    )
                ), let name = info.name, let address = info.address, let port = info.port else { return }

                await viewModel.updateServer(
                    info: ItemInfo(
                        id: item.id, name: name, ipAddress: address, port: port, status: item.status
                    ), infoToReplace: item
                )
            }
        }
        editAction.image = UIImage(systemName: "pencil.line")
        editAction.font = .caption
        editAction.backgroundColor = .main
        return [deleteAction, editAction]
    }

    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        options.transitionStyle = .border
        options.buttonSpacing = 4
        return options
    }
}

extension ServerListViewController {
    private func showAddEditServerAlert(
        in viewController: UIViewController, name: String = "Add", info: ServerInfo = ServerInfo().empty()
    ) async -> ServerInfo? {
        return await AsyncInputAlertController<ServerInfo>(
            title: "\(name) Server",
            message: "Enter new server name, ip address and port.",
            name: info.name,
            address: info.address,
            port: info.port
        )
        .addButton(title: "OK")
        .register(in: viewController) as? ServerInfo
    }
}

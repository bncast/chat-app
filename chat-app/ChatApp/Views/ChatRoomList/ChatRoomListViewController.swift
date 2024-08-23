//
//  ChatroomListViewController.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import UIKit
import SuperEasyLayout

class ChatRoomListViewController: BaseViewController {
    private typealias Section = ChatRoomListViewModel.Section
    private typealias Item = ChatRoomListViewModel.Item
    private typealias ItemInfo = ChatRoomListViewModel.ItemInfo
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    private var dataSource: DataSource?

    private let refreshControl = {
        let view = UIRefreshControl()
        view.tintColor = .active
        return view
    }()

    private lazy var searchBarView = {
        let view = SearchBarView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var layout: UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { [weak self] index, _ in
            guard let self, let sections = dataSource?.snapshot().sectionIdentifiers else { fatalError() }

            switch sections[index] {
            case .myRooms: return getMyRoomsSectionLayout()
            case .otherRooms: return getMyRoomsSectionLayout()
            case .whole: return getWholeSectionLayout()
            }
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundView = nil
        view.backgroundColor = .background(.main)
        view.refreshControl = refreshControl

        NoDataCollectionViewCell.registerCell(to: view)
        ChatRoomListCollectionViewCell.registerCell(to: view)
        ChatRoomListHeaderCollectionReusableView.registerView(to: view)
        return view
    }()

    private lazy var composeButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "plus", withConfiguration: configuration)

        let view = BaseButton(type: .custom)
        view.tintColor = .black
        view.backgroundColor = .active
        view.setImage(image, for: .normal)
        view.layer.cornerRadius = 12
        return view
    }()

    private var navigationBar: ChatRoomListNavigationBar? {
        navigationController?.navigationBar as? ChatRoomListNavigationBar
    }

    private let viewModel = ChatRoomListViewModel()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        navigationBar?.showChatRoomListButtons = true

        Task {
            await IndicatorController.shared.show()
            await viewModel.load()
            await IndicatorController.shared.dismiss()
        }
    }

    // MARK: - Setups

    override func setupNavigation() {
        title = "Chat Rooms"

        setNavigationBarDefaultStyle()
    }

    override func setupLayout() {
        view.backgroundColor = .main

        addSubviews([
            searchBarView,
            collectionView,
            composeButton
        ])
    }

    override func setupConstraints() {
        searchBarView.left == view.left
        searchBarView.right == view.right
        searchBarView.top == view.topMargin + 10

        collectionView.left == view.left
        collectionView.right == view.right
        collectionView.top == searchBarView.bottom + 8
        collectionView.bottom == view.bottom

        composeButton.right == view.right - 25
        composeButton.bottom == view.bottomMargin - 25
        composeButton.width == 50
        composeButton.height == 50
        composeButton.layer.cornerRadius = 25
    }

    override func setupBindings() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.apply(items)
            }
            .store(in: &cancellables)

        searchBarView.textPublisher
            .sink { [weak self] text in
                guard let text else { return }
                self?.viewModel.filterByName(searchKey: text)
            }
            .store(in: &cancellables)
    }

    override func setupActions() {
        navigationBar?.invitationTapHandler = { _ in
            print("[ChatroomListViewController] navigationBar?.invitationTapHandler")
        }
        navigationBar?.profileTapHandler = { [weak self] _ in
            guard let self else { return }

            ProfileViewController.show(on: self)
        }

        composeButton.tapHandlerAsync = { [weak self] _ in
            guard let self else { return }
            CreateChatRoomViewController.show(on: self)
        }

        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
    }

    // MARK: - Other Methods

    @objc
    private func didPullToRefresh(_ sender: UIRefreshControl) {
        Task { await viewModel.load() }
        refreshControl.endRefreshing()
    }

    @MainActor
    private func showChatRoomPasswordAlert(in viewController: UIViewController) async -> String? {
        return await AsyncInputAlertController<String>(
            title: "CHAT ROOM",
            message: "Password required."
        )
        .addButton(title: "Ok")
        .register(in: viewController)
    }

    static func show(on parentViewController: UIViewController) {
        let rootVC = ChatRoomListViewController()
        let navController = UINavigationController(navigationBarClass: ChatRoomListNavigationBar.self, 
                                                   toolbarClass: nil)
        navController.viewControllers = [rootVC]
        navController.modalPresentationStyle = .fullScreen

        parentViewController.present(navController, animated: false)
    }
}

// MARK: - Collection Layout

extension ChatRoomListViewController {
    private func getMyRoomsSectionLayout() -> NSCollectionLayoutSection {
        let unitSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(70))
        let item = NSCollectionLayoutItem(layoutSize: unitSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: unitSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)),
                elementKind: ChatRoomListHeaderCollectionReusableView.viewOfKind,
                alignment: .top
            )
        ]
        return section
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

extension ChatRoomListViewController {
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
                    case .room(let info): self?.getRoomCell(at: indexPath, item: info)
                    case .noData: self?.getNoDataCell(at: indexPath)
                    }
                })
            dataSource?.supplementaryViewProvider = { [weak self] in
                switch $1 {
                case ChatRoomListHeaderCollectionReusableView.viewOfKind:
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

    private func getHeader(at indexPath: IndexPath) -> ChatRoomListHeaderCollectionReusableView {
        let view = ChatRoomListHeaderCollectionReusableView.dequeueView(from: collectionView, for: indexPath)

        switch dataSource?.snapshot().sectionIdentifiers[indexPath.section] {
        case .myRooms: view.title = "MY ROOMS"
        case .otherRooms: view.title = "OTHER ROOMS"
        default: break
        }

        return view
    }

    private func getRoomCell(at indexPath: IndexPath, item: ItemInfo) -> ChatRoomListCollectionViewCell {
        let cell = ChatRoomListCollectionViewCell.dequeueCell(from: collectionView, for: indexPath)
        cell.name = item.name
        cell.preview = item.hasPassword ? "[Private Chat - Password Protected]" : item.preview
        cell.tapHandlerAsync = { [weak self] _ in
            guard let self, let deviceId = AppConstant.shared.deviceId else { return }

            if case .otherRooms = dataSource?.snapshot().sectionIdentifiers[indexPath.section] {

                var password: String?
                if item.hasPassword {
                    password = await showChatRoomPasswordAlert(in: self)
                }
                do {
                    await IndicatorController.shared.show()
                    let _ = try await viewModel.joinChatRoom(
                        roomId: item.roomId, deviceId: deviceId, password: password
                    )
                    await IndicatorController.shared.dismiss()
                    print("[ChatRoomListViewController] Show Messages from Room (\(item.roomId))")
                } catch {
                    print("[ChatRoomListViewController] Error! \(error as! NetworkError)")
                    await IndicatorController.shared.dismiss()
                }
            }

            guard let detail = viewModel.details(for: item) else { return }
            
            ChatRoomViewController.push(on: self, using: detail)
        }
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .background(.mainLight)
        }

        return cell
    }

    private func getNoDataCell(at indexPath: IndexPath) -> NoDataCollectionViewCell {
        NoDataCollectionViewCell.dequeueCell(from: collectionView, for: indexPath)
    }
}

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
        view.tintColor = .background(.main)
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
        view.backgroundColor = .white
        view.refreshControl = refreshControl

        NoDataCollectionViewCell.registerCell(to: view)
        ChatRoomListCollectionViewCell.registerCell(to: view)
        ChatRoomListHeaderCollectionReusableView.registerView(to: view)
        return view
    }()

    private lazy var composeButton: BaseButton = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "plus", withConfiguration: configuration)

        let view = BaseButton(image: image)
        view.layer.cornerRadius = 25
        view.addShadowOval(alpha: 0.5, blur: 8.0)
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
        navigationBar?.title = "Chat Rooms"
        navigationBar?.loadProfileButtonImage()

        Task {
            if !AppConstant.shared.isNewUser {
                await IndicatorController.shared.show()
                await load()
                await IndicatorController.shared.dismiss()
            }
        }
    }

    // MARK: - Setups

    override func setupNavigation() {
        setNavigationBarDefaultStyle()
    }

    override func setupLayout() {
        view.backgroundColor = .main

        addSubviews([
            searchBarView,
            collectionView,
            composeButton
        ])

        guard AppConstant.shared.isNewUser else { return }
        Task {
            await showProfile()
            await IndicatorController.shared.show()
            await load()
            await IndicatorController.shared.dismiss()
        }
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
        navigationBar?.invitationTapHandler = { [weak self] _ in
            guard let self else { return }

            InvitationListViewController.show(on: self)
        }
        navigationBar?.profileTapHandlerAsync = { [weak self] _ in
            guard let self else { return }

            await showProfile()
        }

        composeButton.tapHandlerAsync = { [weak self] _ in
            guard let self else { return }

            guard await CreateChatRoomViewController.show(on: self) else { return }

            await IndicatorController.shared.show()
            await load()
            await IndicatorController.shared.dismiss()
        }

        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
    }

    // MARK: - Other Methods

    @objc
    private func didPullToRefresh(_ sender: UIRefreshControl) {
        if !AppConstant.shared.isNewUser {
            searchBarView.setInitTerm("")
            Task { await load() }
        }
        refreshControl.endRefreshing()
    }

    func load() async {
        searchBarView.setInitTerm("")
        await viewModel.load()
    }

    func showProfile() async {
        await ProfileViewController.show(on: self)
        navigationBar?.loadProfileButtonImage()
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
        cell.imageUrlString = item.imageUrlString
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
                    await load()
                    await IndicatorController.shared.dismiss()
                    print("[ChatRoomListViewController] Show Messages from Room (\(item.roomId))")
                } catch {
                    print("[ChatRoomListViewController] Error! \(error as! NetworkError)")
                    await IndicatorController.shared.dismiss()
                    // TODO: Show error alert
                    return
                }
            }

            guard let detail = viewModel.details(for: item) else { return }
            
            ChatRoomViewController.push(on: self, using: detail)
        }

        return cell
    }

    private func getNoDataCell(at indexPath: IndexPath) -> NoDataCollectionViewCell {
        NoDataCollectionViewCell.dequeueCell(from: collectionView, for: indexPath)
    }
}

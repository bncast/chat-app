//
//  UserListViewModel.swift
//  ChatApp
//
//  Created by William Rena on 8/26/24.
//

import Foundation

final class UserListViewModel {
    enum Section: Int, Hashable, Comparable  {
        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
        case list
        case whole
    }

    enum Item: Hashable {
        case noData
        case user(ItemInfo)
    }

    struct ItemInfo: Hashable, Codable {
        static func == (lhs: ItemInfo, rhs: ItemInfo) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
        var name: String
        var userId: Int
        var isInvited: Bool = false
    }

    @Published var items: [Section: [Item]] = [:]

    private var datasourceItems: [Section: [Item]] = [:]
    var roomId: Int?

    func load() async {
        guard let _ = AppConstant.shared.deviceId,
              let roomId,
              let list = try? await GetUsersEntity(roomId: roomId).run().users else {
            await loadEmptyRooms()
            return
        }

        items = [
            .list: list.compactMap({ item in
                .user(ItemInfo(name: item.name, userId: item.userId))
            })
        ]

        datasourceItems = items
    }

    func loadEmptyRooms() async {
        items = [
            .whole: [.noData]
        ]
    }

    func filterByName(searchKey: String) {
        guard !searchKey.isEmpty
        else {
            items = datasourceItems
            return
        }
        guard let listItems = datasourceItems[.list] else { return }

        items = [
            .list: listItems.filter({
                if case .user(let itemInfo) = $0 {
                    return itemInfo.name.lowercased().contains(searchKey.lowercased())
                }
                return false
            })
        ]
    }

    func inviteUser(userId: Int) async throws {
        guard let roomId,
              let searchIndex = items[.list]?.firstIndex(where: {
                  if case .user(let itemInfo) = $0 {
                      return itemInfo.userId == userId
                  }
                  return false
              }),
              let searchItem = items[.list]?[searchIndex] as? Item
        else { return }

        if case .user(let itemInfo) = searchItem {
            try await SendInvitationEntity(
                inviteeDeviceId: itemInfo.userId, roomId: roomId
            ).run()

            // update filtered item
            items[.list]?[searchIndex] = .user(
                ItemInfo(name: itemInfo.name, userId: itemInfo.userId, isInvited: true)
            )

            // update datasource
            guard let datasourceSearchIndex = datasourceItems[.list]?.firstIndex(where: {
                if case .user(let itemInfo) = $0 {
                    return itemInfo.userId == userId
                }
                return false
            })
            else { return }

            datasourceItems[.list]?[datasourceSearchIndex] = .user(
                ItemInfo(name: itemInfo.name, userId: itemInfo.userId, isInvited: true)
            )
        }
    }
}

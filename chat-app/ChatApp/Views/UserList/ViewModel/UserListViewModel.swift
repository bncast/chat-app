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
        var deviceId: String
        var isInvited: Bool = false
    }

    @Published var items: [Section: [Item]] = [:]

    private var filteredItems: [Section: [Item]] = [:]
    var roomId: Int?

    func load() async {
        guard let deviceId = AppConstant.shared.deviceId,
              let roomId,
              let list = try? await GetUsersEntity(roomId: roomId).run().users else {
            await loadEmptyRooms()
            return
        }

        items = [
            .list: list.compactMap({ item in
                .user(ItemInfo(name: item.name, deviceId: item.deviceId))
            })
        ]

        filteredItems = items
    }

    func loadEmptyRooms() async {
        items = [
            .whole: [.noData]
        ]
    }

    func filterByName(searchKey: String) {
        guard !searchKey.isEmpty
        else {
            items = filteredItems
            return
        }
        guard let listItems = filteredItems[.list] else { return }

        items = [
            .list: listItems.filter({
                if case .user(let itemInfo) = $0 {
                    return itemInfo.name.lowercased().contains(searchKey.lowercased())
                }
                return false
            })
        ]
    }

    func inviteUser(deviceId: String) async {
        guard let searchIndex = items[.list]?.firstIndex(where: {
                  if case .user(let itemInfo) = $0 {
                      return itemInfo.deviceId.contains(deviceId)
                  }
                  return false
              })
        else { return }
        guard let searchItem = items[.list]?[searchIndex] as? Item else { return }

        if case .user(let itemInfo) = searchItem {
            items[.list]?[searchIndex] = .user(
                ItemInfo(name: itemInfo.name, deviceId: itemInfo.deviceId, isInvited: true)
            )
        }
    }
}

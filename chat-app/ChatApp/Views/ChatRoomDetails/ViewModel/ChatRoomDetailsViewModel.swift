//
//  ChatRoomDetailsViewModel.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/21/24.
//

import Foundation

final class ChatRoomDetailsViewModel {
    struct ItemInfo: Hashable, Codable {
        static func == (lhs: ItemInfo, rhs: ItemInfo) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        var id: Int
        var name: String
        var isAdmin: Bool
    }

    @Published var items: [ItemInfo] = [ItemInfo]()

    func load() {
        let itemsToLoad = [ItemInfo(id: 11101, name: "Echo", isAdmin: true),
                           ItemInfo(id: 11102, name: "Zenith", isAdmin: false),
                           ItemInfo(id: 11103, name: "Frost", isAdmin: true),
                           ItemInfo(id: 11104, name: "Vortex", isAdmin: false),
                           ItemInfo(id: 11105, name: "Nebula", isAdmin: false),
                           ItemInfo(id: 11106, name: "Pulse", isAdmin: false),
                           ItemInfo(id: 11107, name: "Orchid", isAdmin: false),
                           ItemInfo(id: 11108, name: "Quasar", isAdmin: false),
                           ItemInfo(id: 11109, name: "Blaze", isAdmin: true),
                           ItemInfo(id: 11110, name: "Jade", isAdmin: true)]

        let sortedItems = itemsToLoad.sorted { (item1, item2) -> Bool in
            if item1.isAdmin != item2.isAdmin {
                return item1.isAdmin && !item2.isAdmin
            }
            return item1.name < item2.name
        }
        items = sortedItems
    }
}

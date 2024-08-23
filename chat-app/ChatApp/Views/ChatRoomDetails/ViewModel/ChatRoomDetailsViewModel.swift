//
//  ChatRoomDetailsViewModel.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/21/24.
//

import Foundation

final class ChatRoomDetailsViewModel {
    struct ItemInfo: Hashable, Codable {
        var id: Int
        var name: String
        var isAdmin: Bool

        static func == (lhs: ItemInfo, rhs: ItemInfo) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(name)
            hasher.combine(isAdmin)
        }
    }

    @Published var items: [ItemInfo] = [ItemInfo]()

    var itemsToLoad = [ItemInfo(id: 11101, name: "Echo", isAdmin: true),
                       ItemInfo(id: 11102, name: "Zenith", isAdmin: false),
                       ItemInfo(id: 11103, name: "Frost", isAdmin: true),
                       ItemInfo(id: 11104, name: "Vortex", isAdmin: false),
                       ItemInfo(id: 11105, name: "Nebula", isAdmin: false),
                       ItemInfo(id: 11106, name: "Pulse", isAdmin: false),
                       ItemInfo(id: 11107, name: "Orchid", isAdmin: false),
                       ItemInfo(id: 11108, name: "Quasar", isAdmin: false),
                       ItemInfo(id: 11109, name: "Blaze", isAdmin: true),
                       ItemInfo(id: 11110, name: "Jade", isAdmin: true)]

    func load() {
        let sortedItems = itemsToLoad.sorted { (item1, item2) -> Bool in
            if item1.isAdmin != item2.isAdmin {
                return item1.isAdmin && !item2.isAdmin
            }
            return item1.name < item2.name
        }
        items = sortedItems
    }

    func updateChatRoomNameInServer(name: String) async throws {
        try await UpdateChatRoomNameEntity(name: name, roomUserId: 11106).run()
    }

    func removeChatRoom(roomUserId: Int) async throws {
        try await RemoveChatRoomEntity(roomUserId: roomUserId).run()
    }

    func setIsAdminInServer(isAdmin: Bool, roomUserId: Int) async throws {
        try await SetIsAdminEntity(isAdmin: isAdmin, roomUserId: roomUserId).run()
    }

    func updateIsAdmin(isAdmin: Bool, roomUserId: Int) {
        guard let index = items.firstIndex(where: { $0.id == roomUserId }) else { return }
        items[index] = ItemInfo(id: roomUserId, name: items[index].name, isAdmin: isAdmin)

    func deleteFromChatRoom(roomUserId: Int, deviceId: String) async throws {
        try await RemoveMemberFromChatRoomEntity(roomUserId: roomUserId, deviceId: deviceId).run()
    }
}

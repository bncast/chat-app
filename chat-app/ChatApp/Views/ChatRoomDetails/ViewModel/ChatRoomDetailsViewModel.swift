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
    @Published var isAdmin: Bool = false

    var details: ChatInfo?
    var itemsToLoad: [ItemInfo] = []
    var updatedName: String?

    func load() {
        guard let details else { fatalError() }

        isAdmin = details.memberDetails.first(where: { $0.roomUserId == details.currentRoomUserId })?.isAdmin ?? false

        itemsToLoad = details.memberDetails.map { ItemInfo(id: $0.roomUserId, name: $0.name, isAdmin: $0.isAdmin)}

        let sortedItems = itemsToLoad.sorted { (item1, item2) -> Bool in
            if item1.isAdmin != item2.isAdmin {
                return item1.isAdmin && !item2.isAdmin
            }
            return item1.name < item2.name
        }
        items = sortedItems
    }

    func updateChatRoomNameInServer(name: String, roomUserId: Int) async throws {
        try await UpdateChatRoomNameEntity(name: name, roomUserId: roomUserId).run()
    }

    func removeChatRoom(roomUserId: Int) async throws {
        guard let deviceId = AppConstant.shared.deviceId else { fatalError() }
        
        try await RemoveChatRoomEntity(deviceId: deviceId, roomUserId: roomUserId).run()
    }
    
    func setIsAdminInServer(isAdmin: Bool, roomUserId: Int) async throws {
        try await SetIsAdminEntity(isAdmin: isAdmin, roomUserId: roomUserId).run()
    }

    func updateIsAdmin(isAdmin: Bool, roomUserId: Int) {
        guard let index = items.firstIndex(where: { $0.id == roomUserId }) else { return }
        items[index] = ItemInfo(id: roomUserId, name: items[index].name, isAdmin: isAdmin)
    }

    func removeUserFromChatRoom(roomUserId: Int) async -> Bool {
        let result = try? await RemoveMemberFromChatRoomEntity(roomUserId: roomUserId).run()

        return result?.success == 1
    }

    func getRoomImageUrlString() -> String {
        guard let details else { return ""}
        return details.imageUrlString
    }
}

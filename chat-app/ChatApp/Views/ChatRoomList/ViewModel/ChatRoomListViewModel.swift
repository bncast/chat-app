//
//  ChatRoomListViewModel.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import Foundation

final class ChatRoomListViewModel {
    enum Section: Hashable {
        case myRooms
        case otherRooms
        case whole
    }

    enum Item: Hashable {
        case noData
        case room(ItemInfo)
    }

    struct ItemInfo: Hashable, Codable {
        static func == (lhs: ItemInfo, rhs: ItemInfo) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        var id = UUID().uuidString
        var name: String
        var preview: String
    }

    @Published var items: [Section: [Item]] = [:]

    func load() async {
        guard let chatrooms = try? await GetChatroomListEntity().run().chatrooms else {
            await loadEmptyRooms()
            return
        }

        let groupedItems = Dictionary(
            grouping: chatrooms,
            by: { $0.isJoined ? Section.myRooms : Section.otherRooms }
        )

        items = [
            .myRooms: groupedItems[.myRooms]?.compactMap { room in
                Item.room(ItemInfo(name: room.chatName, preview: room.preview))
            } ?? [],
            .otherRooms: groupedItems[.otherRooms]?.compactMap { room in
                Item.room(ItemInfo(name: room.chatName, preview: room.preview))
            } ?? []
        ]
    }

    func loadEmptyRooms() async {
        items = [
            .whole: [.noData]
        ]
    }
}

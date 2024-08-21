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
        var roomId: Int
        var name: String
        var preview: String
        var hasPassword: Bool
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
                Item.room(ItemInfo(
                    roomId: room.roomId, name: room.chatName, preview: room.preview, hasPassword: room.hasPassword
                ))
            } ?? [],
            .otherRooms: groupedItems[.otherRooms]?.compactMap { room in
                Item.room(ItemInfo(
                    roomId: room.roomId, name: room.chatName, preview: room.preview, hasPassword: room.hasPassword
                ))
            } ?? []
        ]
    }

    private func loadEmptyRooms() async {
        items = [
            .whole: [.noData]
        ]
    }

    func joinChatRoom(roomId: Int, deviceId: String, password: String?) async throws -> ChatRoomEntity? {
        guard let chatRoom = try await JoinChatRoomEntity(
            roomId: roomId, deviceId: deviceId, password: password
        ).run().chatroom else { return nil }

        return chatRoom
    }
}

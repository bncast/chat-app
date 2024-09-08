//
//  ChatRoomListViewModel.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import Foundation

final class ChatRoomListViewModel {
    enum Section: Int, Hashable, Comparable  {
        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        case myRooms = 0
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

        var roomId: Int
        var name: String
        var preview: String
        var hasPassword: Bool
        var imageUrlString: String
    }

    @Published var items: [Section: [Item]] = [:]

    private var itemsDataSource: [Section: [Item]] = [:]
    private var chatInfos: [ChatInfo] = []

    func load() async {
        guard let chatRooms = try? await GetChatRoomListEntity().run().chatRooms else {
            await loadEmptyRooms()
            return
        }

        let groupedItems = Dictionary(
            grouping: chatRooms,
            by: { $0.isJoined ? Section.myRooms : Section.otherRooms }
        )

        chatInfos = chatRooms.map {
            ChatInfo(name: $0.chatName, roomId: $0.roomId, currentRoomUserId: $0.currentRoomUserId, imageUrlString: $0.chatImageUrl, memberDetails: $0.memberDetails.map({ detail in
                MemberInfo(name: detail.name, isAdmin: detail.isAdmin, roomUserId: detail.roomUserId)
            }))
        }

        items = [
            .myRooms: groupedItems[.myRooms]?.compactMap { room in
                Item.room(ItemInfo(
                    roomId: room.roomId, name: room.chatName, preview: room.preview, hasPassword: false, imageUrlString: room.chatImageUrl
                ))
            } ?? [],
            .otherRooms: groupedItems[.otherRooms]?.compactMap { room in
                Item.room(ItemInfo(
                    roomId: room.roomId, name: room.chatName, preview: room.preview, hasPassword: room.hasPassword, imageUrlString: room.chatImageUrl
                ))
            } ?? []
        ]

        itemsDataSource = items
    }

    func filterByName(searchKey: String) {
        guard !searchKey.isEmpty
        else {
            items = itemsDataSource
            return
        }
        guard let myRooms = itemsDataSource[.myRooms],
              let otherRooms = itemsDataSource[.otherRooms]
        else { return }

        items = [
            .myRooms: myRooms.filter({
                if case .room(let itemInfo) = $0 {
                    return itemInfo.name.lowercased().contains(searchKey.lowercased())
                }
                return false
            }),
            .otherRooms: otherRooms.filter({
                if case .room(let itemInfo) = $0 {
                    return itemInfo.name.lowercased().contains(searchKey.lowercased())
                }
                return false
            })
        ]
    }

    private func loadEmptyRooms() async {
        items = [
            .whole: [.noData]
        ]
    }

    func joinChatRoom(roomId: Int, password: String?) async throws -> ChatRoomEntity? {
        guard let chatRoom = try await JoinChatRoomEntity(
            roomId: roomId, password: password
        ).run().chatRoom else { return nil }

        return chatRoom
    }
    
    func details(for itemInfo: ItemInfo) -> ChatInfo? {
        chatInfos.first(where: { $0.roomId == itemInfo.roomId })
    }

    func requestNotification() async {
        await NotificationManager.shared.requestAuthorization()
    }
}

struct ChatInfo {
    let name: String
    let roomId: Int
    let currentRoomUserId: Int?
    var imageUrlString: String
    let memberDetails: [MemberInfo]
}

struct MemberInfo {
    let name: String
    let isAdmin: Bool
    let roomUserId: Int
}


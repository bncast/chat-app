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
        items = [
            .myRooms: [
                .room(ItemInfo(name: "Lorem", preview: "User1: Lorem ipsum dolor")),
                .room(ItemInfo(name: "Nullam", preview: "User2: Nullam et porttitor justo, eu interdum lacus. Suspendisse feugiat sodales nulla id malesuada. Nunc felis elit, commodo at feugiat vel, consectetur vitae sapien. Vivamus tempor ante at auctor tempus. Sed ligula urna, volutpat vel viverra sit amet, malesuada a nibh.")),
                .room(ItemInfo(name: "Quisque", preview: "User3: Hendrerit mattis arcu nec"))
            ],
            .otherRooms: [
                .room(ItemInfo(name: "Aenean", preview: "User4: Cras nec enim eu nisi maximus dapibus congue eu ligula. Vivamus ac mollis sapien. Nulla interdum dui luctus urna tincidunt fringilla. Donec molestie tellus ac ligula fringilla commodo.")),
                .room(ItemInfo(name: "Donec", preview: "User5: Vivamus ac mollis sapien")),
                .room(ItemInfo(name: "Fusce", preview: "User6: Nulla interdum dui luctus"))
            ]
        ]
    }

    func loadEmptyRooms() async {
        items = [
            .whole: [.noData]
        ]
    }
}

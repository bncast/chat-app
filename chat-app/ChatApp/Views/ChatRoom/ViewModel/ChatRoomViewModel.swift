//
//  ChatRoomViewModel.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/21/24.
//

import Foundation
class ChatRoomViewModel {
    enum Section: Hashable {
        typealias SortIndex = Int

        case main(String, SortIndex)

        var sortIndex: Int {
            if case .main(_, let sortIndex) = self {
                return sortIndex
            } else {
                return -1
            }
        }
    }

    enum Item: Hashable {
        case messageItem(MessageInfo)
    }

    struct MessageInfo: Hashable {
        var id: Int
        var content: String
        var name: String
        var time: String
        var isCurrentUser: Bool
    }

    @Published var items: [Section: [Item]] = [:]

    var details: ChatInfo?

    func load() async {
        guard let deviceId = AppConstant.shared.deviceId,
              var messages = try? await GetChatRoomMessagesEntity(deviceId: deviceId, roomId: 11101).run().messages
        else {
            //TODO: NO DATA
            return
        }

        var items: [Section: [Item]] = [:]
        var sections = [Date]()

        messages.sort { $0.updatedAt < $1.updatedAt }

        for (index, messageItem) in messages.enumerated() {
            if !sections.contains(where: { $0.isSameDayWith(date: messageItem.updatedAt) }) {

                let string = messageItem.updatedAt.toString(by: "MMMM, dd yyyy")

                items[.main(string, index)] = messages
                    .filter { $0.updatedAt.isSameDayWith(date: messageItem.updatedAt) }
                    .map { item in .messageItem(
                        MessageInfo(id: item.messageId,
                                    content: item.content,
                                    name: details?.memberDetails.first(where: { $0.roomUserId == item.authorId})?.name ?? "No name",
                                    time: item.updatedAt.toString(by: "hh:mm a"),
                                    isCurrentUser: item.isCurrentUser == true)
                    ) }

                sections.append(messageItem.updatedAt)
            }
        }

        self.items = items
    }

}

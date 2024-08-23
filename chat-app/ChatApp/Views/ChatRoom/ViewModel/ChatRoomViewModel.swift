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
              let roomId = details?.roomId,
              let roomUserId = details?.currentRoomUserId,
              var messages = try? await GetChatRoomMessagesEntity(deviceId: deviceId, roomId: roomId, roomUserId: roomUserId).run().messages
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

        listenToMessages()
    }

    @discardableResult
    func sendMessage(_ message: String) async -> Bool{
        guard let details, let roomUserId = details.currentRoomUserId else { return false }
        let deviceId = AppConstant.shared.deviceId ?? ""

        let response = try? await SendMessageEntity(deviceId: deviceId, message: message, roomUserId: roomUserId, replyToId: nil).run()

        return response?.success == 1
    }

    var request: GetMessageRespondableEntity?
    private func listenToMessages() {
        guard let details, let deviceId = AppConstant.shared.deviceId else { return }

        Task { [weak self] in
            guard let self else { return }

            do {
                request = try await GetMessageEntity(deviceId: deviceId, roomId: details.roomId).run()
                await load()
            } catch {
                listenToMessages()
            }
        }
    }

}

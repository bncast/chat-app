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
        var imageUrlString: String
        var replyTo: ReplyTo?
    }

    struct ReplyTo: Hashable {
        var isReplyingTo: Int?
        var isReplyingToName: String
        var isReplyingToContent: String?
    }

    @Published var items: [Section: [Item]] = [:]

    var isEditingMessageId: Int?
    var isReplyingMessageId: Int?
    var details: ChatInfo?

    func load() async {
        guard let deviceId = AppConstant.shared.deviceId,
              let roomId = details?.roomId,
              let roomUserId = details?.currentRoomUserId,
              var messages = try? await GetChatRoomMessagesEntity(
                deviceId: deviceId, roomId: roomId, roomUserId: roomUserId
              ).run().messages
        else {
            //TODO: NO DATA
            return
        }

        var items: [Section: [Item]] = [:]
        var sections = [Date]()
        
        messages.sort { $0.createdAt < $1.createdAt }

        for (index, messageItem) in messages.enumerated() {
            if !sections.contains(where: { $0.isSameDayWith(date: messageItem.createdAt) }) {

                let string = messageItem.createdAt.toString(by: "MMMM, dd yyyy")

                items[.main(string, index)] = messages
                    .filter { $0.createdAt.isSameDayWith(date: messageItem.createdAt) }
                    .map { item in
                        var replyTo: ReplyTo?
                        if let _ = item.isReplyingTo {
                            replyTo = ReplyTo(isReplyingTo: item.isReplyingTo,
                                              isReplyingToName: details?.memberDetails.first(
                                                where: { $0.roomUserId == item.isReplyingTo}
                                              )?.name ?? "No name" ,
                                              isReplyingToContent: item.isReplyingToContent)
                        }

                        return .messageItem(
                        MessageInfo(id: item.messageId,
                                    content: item.content,
                                    name: details?.memberDetails.first(
                                        where: { $0.roomUserId == item.authorId}
                                    )?.name ?? "No name",
                                    time: item.createdAt.toString(by: "hh:mm a"),
                                    isCurrentUser: item.isCurrentUser == true,
                                    imageUrlString: item.authorImageUrl, replyTo: replyTo)
                    ) }

                sections.append(messageItem.createdAt)
            }
        }

        self.items = items

        listenToMessages()
    }

    @discardableResult
    func sendMessage(_ message: String) async -> Bool{
        guard let details, let roomUserId = details.currentRoomUserId else { return false }
        let deviceId = AppConstant.shared.deviceId ?? ""

        let response: RespondableApiEntity?

        if let isEditingMessageId {
            response = try? await UpdateMessageEntity(deviceId: deviceId, message: message, messageId: isEditingMessageId).run()
            self.isEditingMessageId = nil
        } else {
            response = try? await SendMessageEntity(deviceId: deviceId, message: message, roomUserId: roomUserId, replyToId: isReplyingMessageId).run()

            self.isReplyingMessageId = nil
        }

        return response?.success == 1
    }

    func deleteMessage(_ messageId: Int) {
        guard let deviceId = AppConstant.shared.deviceId else { return }

        Task {
            let _ = try? await DeleteMessageEntity(deviceId: deviceId, messageId: messageId).run()
        }
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

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
    @Published var typingString: String = String()

    var isEditingMessageId: Int?
    var isReplyingMessageId: Int?
    var details: ChatInfo?

    private var fromDate: Date?
    var isLoaded = false
    var isLoading = true
    var shouldLoadMore = false

    func load(_ date: Date? = nil) async {
        isLoading = true
        guard let roomId = details?.roomId,
              let result = try? await GetChatRoomMessagesEntity(
                roomId: roomId, lastMessageDate: date
              ).run()

        else {
            isLoading = false
            return //TODO: NO DATA
        }

        var messages = result.messages
        fromDate = result.fromDate

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

    func loadMore() {
        guard let fromDate else { return }
        Task { await load(fromDate) }
    }

    @discardableResult
    func sendMessage(_ message: String) async -> Bool{
        guard let details, let roomUserId = details.currentRoomUserId else { return false }
        let response: RespondableApiEntity?

        if let isEditingMessageId {
            response = try? await UpdateMessageEntity(message: message, messageId: isEditingMessageId).run()
            self.isEditingMessageId = nil
        } else {
            response = try? await SendMessageEntity(message: message, roomUserId: roomUserId, replyToId: isReplyingMessageId).run()

            self.isReplyingMessageId = nil
        }

        return response?.success == 1
    }

    func deleteMessage(_ messageId: Int) {
        Task { let _ = try? await DeleteMessageEntity(messageId: messageId).run() }
    }

    func setTyping(isTyping: Bool) {
        guard let roomUserId = details?.currentRoomUserId else { return }
        Task {
            do {
                try await SetTypingEntity(roomUserId: roomUserId, isTyping: isTyping).run()
            } catch {
                print(error)
            }
        }
    }

    var request: GetMessageRespondableEntity?
    private func listenToMessages() {
        guard let details else { return }

        Task { [weak self] in
            guard let self else { return }

            do {
                request = try await GetMessageEntity(roomId: details.roomId).run()
                await load()
                guard let request, let displayNames = request.displayNames else { return }

                var displayNamesCopy = displayNames
                displayNamesCopy.removeAll { $0 == AppConstant.shared.displayName }
                switch displayNamesCopy.count {
                case .zero: typingString = String()
                case 1: guard let firstTypingUser = displayNamesCopy.first else { return }

                    typingString = "\(firstTypingUser) is typing..."
                default: guard let firstTypingUser = displayNamesCopy.first else { return }

                    typingString = "\(firstTypingUser), and +\(displayNamesCopy.count - 1) are typing..."
                }
            } catch {
                listenToMessages()
            }
        }
    }
}

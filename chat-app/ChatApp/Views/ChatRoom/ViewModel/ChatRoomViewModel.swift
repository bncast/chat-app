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
    @Published var peopleCountString: String = String()

    var isEditingMessageId: Int?
    var isReplyingMessageId: Int?
    var details: ChatInfo?

    private var fromDate: Date?
    private var toDate: Date?
    var isLoaded = false
    var isLoadingMore = true
    var shouldLoadMore = false

    func load() async {
        guard let roomId = details?.roomId,
              let result = try? await GetChatRoomMessagesEntity(
                roomId: roomId,
                fromDate: fromDate,
                toDate: toDate
              ).run()

        else {
            isLoadingMore = false
            return //TODO: NO DATA
        }

        var messages = result.messages
        fromDate = result.fromDate
        toDate = result.toDate

        var newItems: [Section: [Item]] = [:]
        var sections = [Date]()
        
        messages.sort { $0.createdAt < $1.createdAt }

        for (_, messageItem) in messages.enumerated() {
            if !sections.contains(where: { $0.isSameDayWith(date: messageItem.createdAt) }) {

                let string = messageItem.createdAt.toString(by: "MMMM, dd yyyy")

                newItems[.main(string, Int(messageItem.createdAt.timeIntervalSince1970))] = messages
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

        items = newItems

        listenToMessages()
    }

    func loadMore() {
        guard let fromDate else { return }
        if let date = Calendar.current.date(byAdding: .day, value: -3, to: fromDate) {
            self.fromDate = date
        }

        Task { await load() }
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
                guard let request else { return }

                if let displayNames = request.displayNames {
                    var displayNamesCopy = displayNames
                    displayNamesCopy.removeAll { $0 == AppConstant.shared.displayName }
                    switch displayNamesCopy.count {
                    case .zero: typingString = String()
                    case 1: guard let firstTypingUser = displayNamesCopy.first else { return }

                        typingString = "\(firstTypingUser) is typing..."
                    default: guard let firstTypingUser = displayNamesCopy.first else { return }

                        typingString = "\(firstTypingUser), and +\(displayNamesCopy.count - 1) are typing..."
                    }
                }

                if let numberInRoom = request.numberInRoom {
                    guard numberInRoom > 1 else {
                        peopleCountString = ""
                        return
                    }

                    peopleCountString = "\(numberInRoom) people in here"
                }

            } catch {
                listenToMessages()
            }
        }
    }
}

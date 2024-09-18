//
//  GetChatRoomMessagesEntity.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/21/24.
//

import Foundation

class GetChatRoomMessagesEntity: RequestableApiEntity {
    typealias ResponseEntity = GetChatRoomMessagesRespondableEntity

    static var method: BaseNetworkOperation.Method { .get }
    var path: String {
        """
        messages?room_id=\(roomId)\(range ?? "")
        """
    }

    var roomId: Int
    var range: String?

    init(roomId: Int, fromDate: Date? = nil, toDate: Date? = nil) {
        self.roomId = roomId
        if let fromDate, let toDate {
            range = "&from_date=\(fromDate.toIso8601)&to_date=\(toDate.toIso8601)"
        }
    }
}

// MARK: Defining response
struct GetChatRoomMessagesRespondableEntity: RespondableApiEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let formatter = Date.utcDateFormatter
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }

    var success: Int
    var error: ErrorMessage?
    var messages: [MessageEntity]
    var fromDate: Date?
    var toDate: Date?
}

struct MessageEntity: Codable {
    var messageId: Int
    var authorId: Int
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isCurrentUser: Bool?
    var authorImageUrl: String
    var isReplyingTo: Int?
    var isReplyingToContent: String?
}


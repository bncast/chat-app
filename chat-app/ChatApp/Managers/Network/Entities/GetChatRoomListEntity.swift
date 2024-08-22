//
//  GetChatroomListEntity.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

class GetChatRoomListEntity: RequestableApiEntity {
    typealias ResponseEntity = GetChatRoomListRespondableEntity

    static var method: BaseNetworkOperation.Method { .get }
    var path: String { "rooms" }
    var body: RequestBody? { GetChatroomRequestBody() }
}

// MARK: - Defining body
struct GetChatroomRequestBody: RequestUrlEncodedBody {
    var encoder: JSONEncoder { JSONEncoder.snakeCaseEncoder() }
}

// MARK: Defining response
struct GetChatRoomListRespondableEntity: RespondableApiEntity {
    var success: Int
    var error: ErrorMessage?
    var chatRooms: [ChatRoomEntity]
}

struct ChatRoomEntity: Codable {
    var roomId: Int
    var authorId: Int
    var authorName: String
    var preview: String
    var isJoined: Bool
    var hasPassword: Bool
    var chatName: String
    var chatImageUrl: String
    var memberDetails: [MemberDetailEntity]
}

struct MemberDetailEntity: Codable {
    var name: String
    var isAdmin: Bool
    var userImageUrl: String
    var roomUserId: Int
}

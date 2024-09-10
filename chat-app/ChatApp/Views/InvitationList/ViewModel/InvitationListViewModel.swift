//
//  InvitationListViewModel.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/26/24.
//

import Foundation

final class InvitationListViewModel {
    enum Section: Int, Hashable, Comparable  {
        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        case list
        case whole
    }

    enum Item: Hashable {
        case noData
        case invitation(ItemInfo)
    }

    struct ItemInfo: Hashable, Codable {
        var id: Int
        var chatRoomName: String
        var roomId: Int
        var isInvited: Bool

        static func == (lhs: ItemInfo, rhs: ItemInfo) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(chatRoomName)
            hasher.combine(isInvited)
        }
    }

    @Published var items: [Section: [Item]] = [:]

    func load() async throws {
        let invitations = try await GetInvitationsListEntity().run().invitations
        if invitations.isEmpty {
            items = [.whole: [.noData]]
            return
        }

        items = [
            .list: invitations.compactMap({ invitation in
                .invitation(
                    ItemInfo(id: invitation.invitationId,
                             chatRoomName: "\(invitation.inviterName) invited you to join \(invitation.chatName)",
                             roomId: invitation.roomId,
                             isInvited: true)
                )
            })
        ]
    }

    func join(roomId: Int, invitationId: Int) async throws -> ChatInfo? {
        guard let result = try await AcceptInvitationEntity(
            invitationId: invitationId, roomId: roomId
        ).run().chatRoom
        else { return nil}

        return ChatInfo(name: result.chatName,
                        roomId: roomId,
                        currentRoomUserId: result.currentRoomUserId,
                        imageUrlString: result.chatImageUrl,
                        memberDetails: result.memberDetails.map {
            MemberInfo(name: $0.name, isAdmin: $0.isAdmin, roomUserId: $0.roomUserId)
        })

    }
}

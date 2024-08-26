//
//  InvitationListViewModel.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/26/24.
//

import Foundation

final class InvitationListViewModel {
    struct ItemInfo: Hashable, Codable {
        var id: Int
        var chatRoomName: String
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

    @Published var items: [ItemInfo] = [ItemInfo]()

    func load() async throws {
        let invitations = try await GetInvitationsListEntity().run().invitations
        items = invitations.compactMap({ invitation in
            ItemInfo(id: invitation.roomId, chatRoomName: "\(invitation.inviterName) invited you to join \(invitation.chatName)", isInvited: true)
        })
    }
}

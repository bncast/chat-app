//
//  CreateChatRoomViewModel.swift
//  ChatApp
//
//  Created by William Rena on 8/21/24.
//

import Foundation

final class CreateChatRoomViewModel {
    func createChatRoom(name: String, deviceId: String, password: String?) async throws -> ChatRoomEntity? {
        guard let chatRoom = try await CreateChatRoomEntity(
            name: name, deviceId: deviceId, password: password
        ).run().chatroom else { return nil }

        return chatRoom
    }
}

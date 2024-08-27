//
//  ProfileViewModel.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/20/24.
//

import Combine

final class ProfileViewModel {
    @Published var displayName: String?
    
    func load() {
        guard let name = AppConstant.shared.displayName else { return }
        displayName = name
    }

    func setDisplayName(name: String) {
        AppConstant.shared.displayName = name
    }
    
    func updateName(name: String) async throws -> String {
        try await UpdateUserEntity(name: name).run().user.userImageUrl
    }
}

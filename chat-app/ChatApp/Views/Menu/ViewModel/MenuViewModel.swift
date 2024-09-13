//
//  MenuViewModel.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/10/24.
//

import Foundation

class MenuViewModel {
    enum Section: Hashable  {
        case list
    }

    enum Item: String, Hashable {
        case profile = "Profile"
        case password = "Change Password"
        case devices = "Devices"
        case logout = "Logout"

        var isFirst: Bool { self == .profile}
    }

    @Published var items: [Section: [Item]] = [:]

    func load() {
        items = [.list: [.profile, .password, .devices, .logout]]
    }

    func logout() async throws {
        try await LogoutUserEntity().run()

        AppConstant.shared.accessToken = nil
        AppConstant.shared.refreshToken = nil
        AppConstant.shared.currentUserImageUrlString = nil
        AppConstant.shared.deviceToken = nil
        AppConstant.shared.displayName = nil
    }
}

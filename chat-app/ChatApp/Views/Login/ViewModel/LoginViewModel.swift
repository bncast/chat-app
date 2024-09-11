//
//  LoginViewModel.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/9/24.
//

import UIKit

class LoginViewModel {
    @Published var errorMessage: String?

    private var deviceName: String {
        UIDevice.current.name
    }

    private var deviceId: String {
        if let deviceId = AppConstant.shared.deviceId {
            return deviceId
        }

        let key = (0..<20).map { _ in
            guard let randomElement = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()
            else { return "" }
            return "\(randomElement)"
        }.joined()

        AppConstant.shared.deviceId = key
        return key
    }

    func login(username: String, password: String) async -> Bool {
        do {
            errorMessage = nil
            let result = try await LoginUserEntity(username: username, password: password, deviceId: deviceId, deviceName: deviceName).run()

            AppConstant.shared.accessToken = result.accessToken
            AppConstant.shared.refreshToken = result.refreshToken
            AppConstant.shared.displayName = result.info?.displayName

            if let imageUrl = result.info?.imageUrl {
                AppConstant.shared.currentUserImageUrlString = imageUrl
            }

            if let currentDeviceTokenU = AppConstant.shared.deviceToken {
                try await SetDeviceTokenEntity(deviceId: AppConstant.shared.deviceId ?? "",
                                               deviceToken: currentDeviceTokenU).run()
            }


            return true
        } catch {
            if let networkError = NetworkError(error) {
                errorMessage = networkError.message
            } else {
                errorMessage = error.localizedDescription
            }
        }

        return false
    }

}

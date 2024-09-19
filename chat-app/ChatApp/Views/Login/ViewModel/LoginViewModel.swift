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

    func login(username: String, password: String) async -> Bool {
        do {
            errorMessage = nil
            let result = try await LoginUserEntity(username: username, password: password, deviceId: AppConstant.shared.getDeviceId(), deviceName: deviceName).run()

            AppConstant.shared.accessToken = result.accessToken
            AppConstant.shared.refreshToken = result.refreshToken
            AppConstant.shared.displayName = result.info?.displayName

            if let imageUrl = result.info?.imageUrl {
                AppConstant.shared.currentUserImageUrlString = imageUrl
            }

            if let currentDeviceTokenU = AppConstant.shared.deviceToken {
                try? await SetDeviceTokenEntity(deviceId: AppConstant.shared.deviceId ?? "",
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

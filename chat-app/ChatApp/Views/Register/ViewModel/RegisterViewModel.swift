//
//  RegisterViewModel.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/9/24.
//

import Foundation

class RegisterViewModel {
    var username: String?
    var password: String?
    var confirmPassword: String?
    var displayName: String?
    
    @Published var errorMessage: String?

    @discardableResult
    func validate() ->  Bool {
        // TODO: Validation
        guard username != nil, displayName != nil, let password, let confirmPassword,
                confirmPassword == password
        else { return false }

        return true
    }

    func submit() async -> Bool{
        guard let username, let password, let displayName else { fatalError() }

        do {
            let result = try await RegisterUserEntity(displayName: displayName, username: username, password: password).run()
            
            AppConstant.shared.accessToken = result.accessToken
            AppConstant.shared.refreshToken = result.refreshToken

            if let imageUrl = result.info?.imageUrl {
                AppConstant.shared.currentUserImageUrlString = imageUrl
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

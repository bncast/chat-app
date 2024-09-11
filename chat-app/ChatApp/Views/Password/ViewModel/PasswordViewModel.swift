//
//  PasswordViewModel.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/10/24.
//

import Foundation

class PasswordViewModel {
    var oldPassword: String?
    var newPassword: String?
    var confirmPassword: String?

    @Published var oldPasswordErrorMessage: String?
    @Published var newPasswordErrorMessage: String?
    @Published var confirmPasswordErrorMessage: String?

    private func validate() -> Bool {
        oldPasswordErrorMessage = nil
        newPasswordErrorMessage = nil
        confirmPasswordErrorMessage = nil

        guard let oldPassword, !oldPassword.isEmpty else {
            oldPasswordErrorMessage = "Cannot be empty."
            return false
        }

        guard let newPassword, !newPassword.isEmpty else {
            newPasswordErrorMessage = "Cannot be empty."
            return false
        }

        guard let confirmPassword, !confirmPassword.isEmpty else {
            confirmPasswordErrorMessage = "Cannot be empty."
            return false
        }

        if newPassword.count < 5 {
            newPasswordErrorMessage = "Must have at least 5 characters."
        }

        if confirmPassword.count < 5 {
            confirmPasswordErrorMessage = "Must have at least 5 characters."
        }

        if confirmPassword != newPassword {
            confirmPasswordErrorMessage = "Does not match."
        }

        return newPasswordErrorMessage == nil
        && confirmPasswordErrorMessage == nil
        && oldPasswordErrorMessage == nil
    }

    func update() async throws -> Bool {
        guard validate(), let oldPassword, let newPassword else { return false }

        try await ChangePasswordEntity(oldPassword: oldPassword, newPassword: newPassword).run()
        return true
    }
}

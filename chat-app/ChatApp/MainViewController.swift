//
//  MainViewController.swift
//  chat-app
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import UIKit

class MainViewController: BaseViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task {
            guard AppConstant.shared.accessToken != nil, let success = try? await ExtendTokenEntity().run().success, success == 1
            else { return LoginViewController.show(on: self) }

            ChatRoomListViewController.show(on: self)
        }
    }

    override func setupLayout() {
        view.backgroundColor = .white
        Task { await NotificationManager.shared.requestAuthorization() }
    }

    override func setupBindings() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name(rawValue: "LogoutNotification"), object: nil, queue: .main
        ) { [weak self] notification in
            if let object: [String: Bool] = notification.object as? [String : Bool],
               object["showAlert"] == true {
                Task {
                    await self?.showAlert()
                    self?.clearData()
                    self?.redirectToLogin()
                }
                return
            }
            
            Task {
                self?.clearData()
                self?.redirectToLogin()
            }
        }
    }
    
    private func clearData() {
        AppConstant.shared.accessToken = nil
        AppConstant.shared.refreshToken = nil
        AppConstant.shared.currentUserImageUrlString = nil
        AppConstant.shared.displayName = nil
    }

    private func showAlert() async {
        guard let top = getTopViewController() else { return }

        await AsyncAlertController<Void>(
            title: "Logged out",
            message: "You are logged out from the app."
        )
        .addButton(title: "OK", returnValue: Void())
        .register(in: top)
    }

    private func redirectToLogin() {
        presentedViewController?.dismiss(animated: true)
    }
}

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

        let rootVC = ChatRoomListViewController()
        let navController = UINavigationController(navigationBarClass: ChatRoomListNavigationBar.self, toolbarClass: nil)
        navController.viewControllers = [rootVC]
        navController.modalPresentationStyle = .fullScreen

        present(navController, animated: false)
    }

    override func setupActions() {
        view.backgroundColor = UIColor.main

        Task {
            do {
                let request = try await GetChatRoomMessagesEntity(deviceId: "TEMP", roomId: 10001).run()
                print("NINOTEST", request)
            } catch {
                var message = ""
                message += "Error \(error.localizedDescription)"
            }
        }
    }
}

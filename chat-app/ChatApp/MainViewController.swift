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
            guard let success = try? await ExtendTokenEntity().run().success, success == 1
            else { return LoginViewController.show(on: self) }

            ChatRoomListViewController.show(on: self)
        }
    }

    override func setupLayout() {
        view.backgroundColor = .white
    }
}

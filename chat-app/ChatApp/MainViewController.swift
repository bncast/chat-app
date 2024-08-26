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
        
        ChatRoomListViewController.show(on: self)
    }
}

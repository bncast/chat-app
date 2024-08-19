//
//  MainViewController.swift
//  chat-app
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import UIKit

class MainViewController: BaseViewController {
    override func setupActions() {
        view.backgroundColor = UIColor.main

        Task {
            do {
                let request = try await AppVersionEntity().run()
            } catch {
                var message = ""
                message += "Error \(error.localizedDescription)"
            }
        }
    }
}

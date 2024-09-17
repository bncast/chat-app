//
//  AsyncAlertController.swift
//  ChatApp
//
//  Created by William Rena on 8/21/24.
//

import UIKit

class AsyncAlertController<T> {
    private let alertController: UIAlertController
    private var continuation: CheckedContinuation<T, Never>?

    private let title: String?
    private let message: String?

    init(title: String? = nil, message: String? = nil,
         name: String? = nil, preferredStyle: UIAlertController.Style = .alert) {
        self.title = title
        self.message = message
        self.alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        self.alertController.view.tintColor = UIColor.accent
    }

    @discardableResult
    func addButton(
        title: String, style: UIAlertAction.Style = .default, isPreferred: Bool = false,
        isCancel: Bool = false, returnValue: T
    ) -> Self {
        let newAlertAction = UIAlertAction(title: title, style: style) { [weak self] action in
            guard let continuation = self?.continuation else { fatalError("You must use registerAsync.") }
            continuation.resume(returning: returnValue)
        }
        alertController.addAction(newAlertAction)
        if isPreferred { alertController.preferredAction = newAlertAction }
        return self
    }

    @discardableResult
    func register(in parentViewController: UIViewController) async -> T {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            DispatchQueue.main.async {
                parentViewController.present(self.alertController, animated: true)
            }
        }
    }
}

class AsyncInputAlertController<T> {
    private let alertController: UIAlertController
    private var continuation: CheckedContinuation<Any?, Never>?

    private let title: String?
    private let message: String?

    typealias ServerInfo = ServerListViewController.ServerInfo

    init(title: String? = nil, message: String? = nil,
         name: String? = nil, preferredStyle: UIAlertController.Style = .alert
    ) {
        self.title = title
        self.message = message

        self.alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        self.alertController.addTextField { textField in
            textField.text = name
        }
        self.alertController.view.tintColor = UIColor.accent
    }

    init(title: String? = nil, message: String? = nil,
         name: String? = nil, address: String? = nil, port: String? = nil, preferredStyle: UIAlertController.Style = .alert
    ) {
        self.title = title
        self.message = message

        self.alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        self.alertController.addTextField { textField in
            textField.placeholder = "Server Name"
            guard let name, !name.isEmpty else { return }

            textField.text = name
        }
        self.alertController.addTextField { textField in
            textField.placeholder = "IP Address"
            guard let address, !address.isEmpty else { return }

            textField.text = address
        }
        self.alertController.addTextField { textField in
            textField.placeholder = "PORT"
            guard let port, !port.isEmpty else { return }

            textField.text = port
        }
        self.alertController.view.tintColor = UIColor.accent
    }

    @discardableResult
    func addButton(
        title: String, style: UIAlertAction.Style = .default, isPreferred: Bool = false,
        isCancel: Bool = false
    ) -> Self {
        let newAlertAction = UIAlertAction(title: title, style: style) { [weak self] action in
            guard let continuation = self?.continuation else { fatalError("You must use registerAsync.") }
            guard let alertController = self?.alertController else { return }

            guard let fields = alertController.textFields else { return }
            guard fields.count > 1 else {
                guard let inputText = fields.first else { return }

                continuation.resume(returning: (inputText.text))
                return
            }

            continuation.resume(returning: (
                ServerInfo(name: fields[0].text,
                           address: fields[1].text,
                           port: fields[2].text)
            ))
        }
        alertController.addAction(newAlertAction)
        if isPreferred { alertController.preferredAction = newAlertAction }
        return self
    }

    @discardableResult
    func register(in parentViewController: UIViewController) async -> Any? {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            DispatchQueue.main.async {
                parentViewController.present(self.alertController, animated: true)
            }
        }
    }
}

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
    private var continuation: CheckedContinuation<String?, Never>?

    private let title: String?
    private let message: String?

    init(title: String? = nil, message: String? = nil,
         name: String? = nil, preferredStyle: UIAlertController.Style = .alert
    ) {
        self.title = title
        self.message = message

        self.alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        self.alertController.addTextField()
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

            let inputText = alertController.textFields!.first?.text
            continuation.resume(returning: (inputText))
        }
        alertController.addAction(newAlertAction)
        if isPreferred { alertController.preferredAction = newAlertAction }
        return self
    }

    @discardableResult
    func register(in parentViewController: UIViewController) async -> String? {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            DispatchQueue.main.async {
                parentViewController.present(self.alertController, animated: true)
            }
        }
    }
}

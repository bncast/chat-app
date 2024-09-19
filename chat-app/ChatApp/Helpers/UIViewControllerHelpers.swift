//
//  UIViewControllerHelpers.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import UIKit

extension UIViewController {
    func addSubviews(_ views: [UIView]) {
        view.addSubviews(views)
    }

    func setNavigationBarDefaultStyle(backgroundColor: UIColor = .main, tintColor: UIColor = .mainBackground) {
        let image = UIImage(systemName: "chevron.left")
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.setBackIndicatorImage(image, transitionMaskImage: image)
            appearance.backgroundColor = backgroundColor
            appearance.shadowColor = .clear
            setNavigationBarAppearance(appearance)
        } else {
            let navigationBar = navigationController?.navigationBar
            navigationBar?.standardAppearance.setBackIndicatorImage(image, transitionMaskImage: image)
            navigationBar?.standardAppearance.backgroundColor = backgroundColor
            navigationBar?.standardAppearance.shadowColor = .clear
        }
        navigationController?.navigationBar.tintColor = tintColor
        navigationItem.backButtonTitle = ""
    }

    func setNavigationBarAppearance(_ appearance: UINavigationBarAppearance) {
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }

    func dismissAllModalAsync(animated: Bool = true, completionHandler: (() async -> Void)? = nil) async {
        guard let presentedViewController else {
            await completionHandler?()
            return
        }
        if let snapshotView = presentedViewController
            .view.snapshotView(afterScreenUpdates: false) {
            presentedViewController.view.addSubview(snapshotView)
            presentedViewController.modalTransitionStyle = .coverVertical
        }
        if !isBeingDismissed {
            await dismissAsync(animated: animated)
        } else {
            await completionHandler?()
        }
    }

    func dismissAllModal(animated: Bool = true, completionHandler: (() -> Void)? = nil) {
        guard let presentedViewController else {
            completionHandler?()
            return
        }
        if let snapshotView = presentedViewController
            .view.snapshotView(afterScreenUpdates: false) {
            presentedViewController.view.addSubview(snapshotView)
            presentedViewController.modalTransitionStyle = .coverVertical
        }
        if !isBeingDismissed {
            dismiss(animated: animated, completion: completionHandler)
        } else {
            completionHandler?()
        }
    }

    func dismissAsync(animated: Bool) async {
        await withCheckedContinuation { [weak self] continuation in
            self?.dismiss(animated: animated) {
                continuation.resume()
            }
        }
    }

    func getTopViewController() -> UIViewController? {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .filter({ $0.isKeyWindow }).first else {
            return nil
        }

        var topController = keyWindow.rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }

        return topController
    }
}

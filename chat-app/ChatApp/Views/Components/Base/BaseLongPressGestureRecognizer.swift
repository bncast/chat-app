//
//  BaseLongPressGestureRecognizer.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/22/24.
//

import UIKit

class BaseLongPressGestureRecognizer: UILongPressGestureRecognizer {
    private var isInitialized = false

    var longPressHandler: ((UILongPressGestureRecognizer) -> Void)? {
        didSet {
            guard !isInitialized else { return }
            isInitialized = true
            addTarget(self, action: #selector(longPressed(_:)))
        }
    }

    init(on view: UIView) {
        super.init(target: nil, action: nil)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(self)
    }

    func registerGesture(on view: UIView) {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(self)
    }

    @objc private func longPressed(_: UILongPressGestureRecognizer) {
        longPressHandler?(self)
    }
}

//
//  BaseButton.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import UIKit
import Combine

class BaseButton: UIButton {
    var tapHandler: ((UIButton) -> Void)?
    var tapHandlerAsync: ((UIButton) async -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    convenience init(image: UIImage?) {
        let frame = CGRect(origin: CGPoint.zero, size: image?.size ?? CGSize.zero)
        self.init(frame: frame)
        setImage(image, for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    deinit {

    }

    func setup() {
        addTarget(self, action: #selector(touchUpInsideButton(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(touchDownButton(_:)), for: .touchDown)

        isEnabled = true
        isExclusiveTouch = true
    }
}

extension BaseButton {
    @objc func touchUpInsideButton(_: Any) {
        if let tapHandlerAsync {
            Task { await tapHandlerAsync(self) }
            return
        } else if let tapHandler {
            tapHandler(self)
        }
    }

    @objc func touchDownButton(_: Any) {

    }
}

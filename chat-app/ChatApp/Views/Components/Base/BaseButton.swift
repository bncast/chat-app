//
//  BaseButton.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import UIKit
import Combine

class BaseButton: UIButton {
    private let isProcessingLock = NSLock()
    var isProcessing = false {
        willSet { isProcessingLock.lock() }
        didSet { isProcessingLock.unlock() }
    }

    private var oldIsEnabled = false
    override var isEnabled: Bool {
        didSet {
            if isProcessing { oldIsEnabled = isEnabled }
        }
    }

    var titleColors: [UIControl.State: UIColor?] = [:] {
        didSet {
            titleColors.forEach { state, color in
                guard let attributedString = attributedTitle(for: state) else { return }
                guard let color else { return }
                let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
                mutableAttributedString
                    .addAttribute(.foregroundColor,
                                  value: color,
                                  range: NSRange(location: 0, length: attributedString.string.count))
                setAttributedTitle(mutableAttributedString, for: state)
            }
        }
    }

    var backgroundColors: [UIControl.State: UIColor?] = [
        UIControl.State.normal: .clear,
        UIControl.State.disabled: .clear
    ] {
        didSet {
            if let color = backgroundColors[state] {
                backgroundColor = color
            }
        }
    }

    var tapHandler: ((BaseButton) -> Void)?
    var tapHandlerAsync: ((BaseButton) async -> Void)?

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

// MARK: - Actions
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

extension UIControl.State: Hashable {}

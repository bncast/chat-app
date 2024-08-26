//
//  BaseSwipeCollectionViewCell.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/24/24.
//

import Combine
import SwipeCellKit
import UIKit

class BaseSwipeCollectionViewCell: SwipeCollectionViewCell {
    class var identifier: String {
        let name = NSStringFromClass(self)
        let components = name.components(separatedBy: ".")
        return components.last ?? "Unknown" + "Identifier"
    }

    class func registerCell(to collectionView: UICollectionView) {
        collectionView.register(self, forCellWithReuseIdentifier: identifier)
    }

    class func dequeueCell(from collectionView: UICollectionView, for indexPath: IndexPath) -> Self {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: identifier, for: indexPath
        ) as? Self else {
            fatalError("Could not get cell object. identifier => \(identifier)")
        }
        return cell
    }

    private weak static var tappingCell: BaseSwipeCollectionViewCell?
    private static var tapControllSemaphore = DispatchSemaphore(value: 0)
    private static var tapQueue = DispatchQueue(label: "CollectionViewCellTapQueue")

    private var isRippleAnimating = false
    private var needDeleteRipple = false

    lazy var observers = [NSKeyValueObservation]()
    lazy var cancellables = Set<AnyCancellable>()

    override var reuseIdentifier: String? {
        BaseCollectionViewCell.identifier
    }

    var selectionBackView: UIView? {
        didSet {
            guard let view = selectionBackView else {
                originSelectionBackViewBackgroundColor = .white
                return
            }
            originSelectionBackViewBackgroundColor = view.backgroundColor
        }
    }

    var highlightColor: UIColor? = .black.withAlphaComponent(0.3)
    var tapHandler: ((BaseSwipeCollectionViewCell) -> Void)?
    var tapHandlerAsync: ((BaseSwipeCollectionViewCell) async -> Void)?
    var needRipple = true

    private var originSelectionBackViewBackgroundColor: UIColor?
    private var rippleView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    deinit {
        rippleView = nil
    }

    func setup() {
        setupLayout()
        setupConstraints()
        setupBindings()
        setupActions()
    }

    func setupLayout() {}
    func setupConstraints() {}
    func setupBindings() {}
    func setupActions() {}
}

// MARK: - Display ripple
extension BaseSwipeCollectionViewCell {
    func tryTap() -> Bool {
        var result = false
        BaseSwipeCollectionViewCell.tapQueue.async {
            if BaseSwipeCollectionViewCell.tappingCell != nil {
                result = false
            } else {
                BaseSwipeCollectionViewCell.tappingCell = self
                result = true
            }
            BaseSwipeCollectionViewCell.tapControllSemaphore.signal()
        }
        BaseSwipeCollectionViewCell.tapControllSemaphore.wait()
        return result
    }

    func releaseTap() {
        BaseSwipeCollectionViewCell.tapQueue.async {
            if BaseSwipeCollectionViewCell.tappingCell == self {
                BaseSwipeCollectionViewCell.tappingCell = nil
            }
            BaseSwipeCollectionViewCell.tapControllSemaphore.signal()
        }
        BaseSwipeCollectionViewCell.tapControllSemaphore.wait()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let selectionBackView,
              let touchPoint = touches.first?.location(in: self),
              selectionBackView.frame.contains(touchPoint),
              needRipple,
              tryTap()
        else { return }

        if let result = self.hitTest(touchPoint, with: event), result is UntouchableView {
            return
        }

        isRippleAnimating = true
        defer {
            super.touchesBegan(touches, with: event)
        }
        let rippleView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 10.0, height: 10.0)))
        rippleView.backgroundColor = highlightColor
        rippleView.alpha = 0.5
        rippleView.layer.cornerRadius = 5.0
        rippleView.center = CGPoint(x: touchPoint.x - selectionBackView.frame.minX,
                                    y: touchPoint.y - selectionBackView.frame.minY)
        selectionBackView.addSubview(rippleView)
        selectionBackView.clipsToBounds = true
        self.rippleView = rippleView
        let scale = max(bounds.width / 3.0, bounds.height / 3.0)
        UIView.animate(withDuration: 0.33, animations: {
            rippleView.transform = CGAffineTransform(scaleX: scale, y: scale)
            rippleView.alpha = 0.3
        }, completion: { [weak self] _ in
            self?.isRippleAnimating = false
            if self?.needDeleteRipple ?? false {
                UIView.animate(withDuration: 0.2, animations: {
                    rippleView.alpha = 0.0
                }, completion: { [weak self] _ in
                    self?.rippleView = nil
                    self?.needDeleteRipple = false
                })
            }
        })
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard needRipple else {
            if let tapHandlerAsync {
                Task { [weak self] in
                    guard let self else { return }
                    await tapHandlerAsync(self)
                }
            } else {
                tapHandler?(self)
            }
            return
        }
        defer {
            releaseTap()
        }
        guard let rippleView else { return }
        defer {
            super.touchesEnded(touches, with: event)
        }
        if isRippleAnimating {
            needDeleteRipple = true
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                rippleView.alpha = 0.0
            }, completion: { [weak self] _ in
                self?.rippleView = nil
            })
        }
        if let tapHandlerAsync {
            Task { [weak self] in
                guard let self else { return }
                await tapHandlerAsync(self)
            }
        } else {
            tapHandler?(self)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            releaseTap()
            super.touchesCancelled(touches, with: event)
        }
        guard let rippleView else { return }
        self.rippleView = nil
        if isRippleAnimating {
            needDeleteRipple = true
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                rippleView.alpha = 0.0
            }, completion: { [weak self] _ in
                self?.rippleView = nil
            })
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let result = super.hitTest(point, with: event) else { return nil }
        return rippleView == result ? self : result
    }
}

class UntouchableView: BaseView {
    override func setup() {
        isUserInteractionEnabled = true
        super.setup()
    }
}


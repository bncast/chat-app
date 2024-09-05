//
//  BaseCollectionViewCell.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    var tapHandler: ((BaseCollectionViewCell) -> Void)?
    var tapHandlerAsync: ((BaseCollectionViewCell) async -> Void)?

    private var originSelectionBackViewBackgroundColor: UIColor?
    var selectionBackView: UIView? {
        didSet {
            guard let view = selectionBackView else {
                originSelectionBackViewBackgroundColor = .white
                return
            }
            originSelectionBackViewBackgroundColor = view.backgroundColor
        }
    }
    private weak static var tappingCell: BaseCollectionViewCell?
    private static var tapControllSemaphore = DispatchSemaphore(value: 0)
    private static var tapQueue = DispatchQueue(label: "CollectionViewCellTapQueue")

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

    override var reuseIdentifier: String? {
        BaseCollectionViewCell.identifier
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

    }

    override func prepareForReuse() {

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

extension BaseCollectionViewCell {
    func tryTap() -> Bool {
        var result = false
        BaseCollectionViewCell.tapQueue.async {
            if BaseCollectionViewCell.tappingCell != nil {
                result = false
            } else {
                BaseCollectionViewCell.tappingCell = self
                result = true
            }
            BaseCollectionViewCell.tapControllSemaphore.signal()
        }
        BaseCollectionViewCell.tapControllSemaphore.wait()
        return result
    }

    func releaseTap() {
        BaseCollectionViewCell.tapQueue.async {
            if BaseCollectionViewCell.tappingCell == self {
                BaseCollectionViewCell.tappingCell = nil
            }
            BaseCollectionViewCell.tapControllSemaphore.signal()
        }
        BaseCollectionViewCell.tapControllSemaphore.wait()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let selectionBackView,
              let touchPoint = touches.first?.location(in: self),
              selectionBackView.frame.contains(touchPoint),
              tryTap()
        else { return }

        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let tapHandlerAsync {
            Task { [weak self] in
                guard let self else { return }
                await tapHandlerAsync(self)
            }
        } else {
            tapHandler?(self)
        }
        super.touchesEnded(touches, with: event)
    }
}

//
//  BaseCollectionReusableView.swift
//  ChatApp
//
//  Created by William Rena on 8/19/24.
//

import UIKit
import Combine

class BaseCollectionReusableView: UICollectionReusableView {
    class var identifier: String {
        let name = NSStringFromClass(self)
        let components = name.components(separatedBy: ".")
        return components.last ?? "Unknown" + "Identifier"
    }

    class var isHeader: Bool {
        fatalError("You must set isHeader.")
    }

    class var viewOfKind: String { identifier }

    class func registerView(to collectionView: UICollectionView) {
        collectionView.register(
            self,
            forSupplementaryViewOfKind: viewOfKind,
            withReuseIdentifier: identifier
        )
    }

    class func dequeueView(from collectionView: UICollectionView,
                           for indexPath: IndexPath) -> Self {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: viewOfKind,
            withReuseIdentifier: identifier,
            for: indexPath
        ) as? Self
        else { fatalError("Could not get view object. identifier => \(identifier)") }
        return view
    }

    lazy var cancellables = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
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

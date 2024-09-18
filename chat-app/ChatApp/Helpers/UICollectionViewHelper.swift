//
//  UICollectionViewHelper.swift
//  ChatApp
//
//  Created by Niño Castorico on 8/23/24.
//

import UIKit

extension UICollectionView {
    func scrollToBottom() {
        let lastSection = numberOfSections - 1
        let lastRow = numberOfItems(inSection: lastSection)
        let indexPath = IndexPath(row: lastRow - 1, section: lastSection)
        scrollToItem(at: indexPath, at: .bottom, animated: true)
    }

    func isOnBottom() -> Bool {
        return self.contentOffset.y > self.contentSize.height - self.frame.size.height * 1.5
    }
}

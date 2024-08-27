//
//  UIImageViewHelpers.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/27/24.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        self.kf.setImage(with: url,placeholder: UIImage(systemName: "person.crop.circle.fill")?
            .withRenderingMode(.alwaysTemplate), options: [.cacheOriginalImage])
    }
}

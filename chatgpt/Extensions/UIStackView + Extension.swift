//
//  UIStackView + Extension.swift
//  chatgpt
//
//  Created by Yuriy on 21.01.2025.
//

import UIKit

extension UIStackView {
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            subview.removeFromSuperview()
            return allSubviews + [subview]
        }
    }
}


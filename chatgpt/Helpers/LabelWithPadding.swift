//
//  LabelWithPadding.swift
//  chatgpt
//
//  Created by Yuriy on 24.01.2025.
//

import UIKit

final class LabelWithPadding: UILabel {
    
    var insets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetBounds = bounds.inset(by: insets)
        let textRect = super.textRect(forBounds: insetBounds, limitedToNumberOfLines: numberOfLines)
        return textRect.offsetBy(dx: insets.left, dy: insets.top)
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
}


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
        let textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        print(textRect)
        return textRect.inset(by: insets.inverted())
    }
}

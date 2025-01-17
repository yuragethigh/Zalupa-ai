//
//  UIBarButtonItem + Extension.swift
//  GPTClone
//
//  Created by Yuriy on 01.10.2024.
//

import UIKit

extension UIBarButtonItem {
    
    convenience init(customView: UIView, target: Any?, action: Selector?, frame: CGFloat? = nil) {
     
        let button = UIButton()
        customView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: customView.topAnchor),
            button.leadingAnchor.constraint(equalTo: customView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: customView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: customView.bottomAnchor),
        ])
        
        if let target = target, let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        
        self.init(customView: customView)
    }
    
    convenience init(image: UIImage, target: Any?, action: Selector?) {
        let button = ButtonWithTouchSize()
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        if let target = target, let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        
        let containerView = UIView(frame: button.bounds)
        containerView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        
        self.init(customView: containerView)
    }
    
}

class ButtonWithTouchSize: UIButton {
    
    var touchAreaPadding: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
    
    override func point(inside point: CGPoint,
                        with event: UIEvent?) -> Bool {
        let rect = bounds.inset(by: touchAreaPadding.inverted())
        return rect.contains(point)
    }
}

private extension UIEdgeInsets {
    func inverted() -> Self {
        return .init(top: -top, left: -left, bottom: -bottom, right: -right)
    }
}

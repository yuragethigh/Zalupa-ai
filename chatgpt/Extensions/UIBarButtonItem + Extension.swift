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
        let button = ButtonWithLargerHitArea(type: .custom)
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

class ButtonWithLargerHitArea: UIButton {
    private let hitAreaInset: CGFloat = -50

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let largerArea = bounds.insetBy(dx: hitAreaInset, dy: hitAreaInset)
        return largerArea.contains(point)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let largerArea = bounds.insetBy(dx: hitAreaInset, dy: hitAreaInset)
        if largerArea.contains(point) {
            return self
        }
        return nil
    }
}

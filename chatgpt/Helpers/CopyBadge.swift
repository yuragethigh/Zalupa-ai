//
//  CopieView.swift
//  chatgpt
//
//  Created by Yuriy on 27.01.2025.
//

import UIKit

final class CopyBadge: UIView {
    
    var text = "" {
        didSet { badgeLabel.text = text }
    }
    
    var alphaLabel: CGFloat = 0 {
        didSet { badgeLabel.alpha = alpha}
    }
    
    private let badgeLabel: LabelWithPadding = {
        let label = LabelWithPadding()
        label.font = .SFProText(weight: .medium, size: 15)
        label.textAlignment = .center
        label.backgroundColor = .mainAccent
        label.layer.cornerRadius = 18
        label.clipsToBounds = true
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        addSubview(badgeLabel)
        
        NSLayoutConstraint.activate([
            badgeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            badgeLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func animate() {
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.badgeLabel.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2, animations: {
                self.badgeLabel.alpha = 0
            }, completion: nil)
        })
    }
    
}

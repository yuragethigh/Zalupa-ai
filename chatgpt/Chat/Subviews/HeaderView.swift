//
//  HeaderView.swift
//  chatgpt
//
//  Created by Yuriy on 22.01.2025.
//

import UIKit

final class HeaderView: UICollectionReusableView {
    static let identifier = String(describing: HeaderView.self)
    
    let titleLabel: LabelWithPadding = {
        let label = LabelWithPadding()
        label.insets = .init(top: 0, left: 16, bottom: 0, right: 16)
        label.font = .SFProText(weight: .medium, size: 15)
        label.textColor = .white
        label.backgroundColor = .textfield
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


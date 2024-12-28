//
//  ChatListSectionHeader.swift
//  chatgpt
//
//  Created by Yuriy on 27.12.2024.
//

import UIKit

final class ChatListSectionHeader: UIView {
    
    private let headerLabel: UILabel = {
        let headerLabel = UILabel()
        headerLabel.textColor = .white
        headerLabel.font = .SFProText(weight: .semibold, size: 30)
        headerLabel.text = "История чатов"
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        return headerLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .bg
        setupConstraints()
    }
    
    // MARK: Private methods
    
    private func setupConstraints() {
        addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//
//  AnotherAppTVHeader.swift
//  chatgpt
//
//  Created by Yuriy on 02.01.2025.
//

import UIKit

final class AnotherAppTVHeader: UIView {
    
    // MARK: - Properties
    
    private let textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = .SFProText(weight: .semibold, size: 18)
        textLabel.text = "Другие наши приложения:"
        textLabel.textColor = .white
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .bg
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private Methods

    private func setupConstraints() {
        addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
    
}


//
//  ForescoLogoView.swift
//  chatgpt
//
//  Created by Yuriy on 15.01.2025.
//

import UIKit

final class ForescoLogoView: UIView {
    
    // MARK: - Properties
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "\(SettingsLocs.versionApp) \(Bundle.main.releaseVersionNumberPretty)"
        label.font = .SFProText(weight: .regular, size: 14)
        label.textColor = .textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let secondaryLabel: UILabel = {
        let label = UILabel()
        label.text = "Разработано в"
        label.font = .SFProText(weight: .regular, size: 14)
        label.textColor = .textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .foreskoLogo
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var horizontalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [secondaryLabel, imageView])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var verticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [versionLabel, horizontalStack])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        return stack
    }()
    
    var bottomConstraints: NSLayoutConstraint?
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        setupConstraints()
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    func setupConstraints() {
        addSubview(verticalStack)
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: topAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc private func handleTap() {
        Deeplinks.open(type: .foreskoSite)
    }
    
    //  MARK: - Public Methods
    
}



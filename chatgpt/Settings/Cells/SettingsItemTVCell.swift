//
//  SettingsItemTVCell.swift
//  chatgpt
//
//  Created by Yuriy on 02.01.2025.
//

import UIKit

final class SettingsItemTVCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = String(describing: SettingsItemTVCell.self)
    
    private let backgroundContainer: UIView = {
        let backgroundContainer = UIView()
        backgroundContainer.backgroundColor = .card
        backgroundContainer.layer.cornerRadius = 16
        backgroundContainer.layer.masksToBounds = true
        backgroundContainer.translatesAutoresizingMaskIntoConstraints = false
        return backgroundContainer
    }()
    
    private let devider: UIView = {
        let devider = UIView()
        devider.backgroundColor = .topStroke
        devider.alpha = 0
        devider.translatesAutoresizingMaskIntoConstraints = false
        return devider
    }()
    
    private let logoImage: UIImageView = {
        let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        return logoImage
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .SFProText(weight: .regular, size: 15)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let arrowImage: UIImageView = {
        let arrowImage = UIImageView()
        arrowImage.contentMode = .scaleAspectFit
        arrowImage.image = .arrowrightA
        arrowImage.tintColor = .topStroke
        arrowImage.translatesAutoresizingMaskIntoConstraints = false
        return arrowImage
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        setupContstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private Methods
    
    private func setupContstraints() {
        contentView.addSubview(backgroundContainer)
        
        backgroundContainer.addSubview(logoImage)
        backgroundContainer.addSubview(titleLabel)
        backgroundContainer.addSubview(arrowImage)
        backgroundContainer.addSubview(devider)
        
        NSLayoutConstraint.activate([
            backgroundContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backgroundContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            backgroundContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            logoImage.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 14),
            logoImage.centerYAnchor.constraint(equalTo: backgroundContainer.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: backgroundContainer.centerYAnchor),
            
            arrowImage.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor, constant: -14),
            arrowImage.centerYAnchor.constraint(equalTo: backgroundContainer.centerYAnchor),
            
            devider.bottomAnchor.constraint(equalTo: backgroundContainer.bottomAnchor),
            devider.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 14),
            devider.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor, constant: -14),
            devider.heightAnchor.constraint(equalToConstant: 0.5)

        ])
    }
    
    // MARK: - Public Methods
    
    func updateCorners(isFirst: Bool, isLast: Bool) {
        var maskedCorners: CACornerMask = []
        
        if isFirst {
            maskedCorners.insert(.layerMinXMinYCorner)
            maskedCorners.insert(.layerMaxXMinYCorner)
        }
        
        if isLast {
            maskedCorners.insert(.layerMinXMaxYCorner)
            maskedCorners.insert(.layerMaxXMaxYCorner)
        }
        
        backgroundContainer.layer.maskedCorners = maskedCorners
    }
    
    func updateDevider(isLast: Bool) {
        if isLast {
            devider.alpha = 0
        } else {
            devider.alpha = 1
        }
    }
    
    func configure(_ item: SettingsItemConfiguration) {
        self.logoImage.image = item.image
        self.titleLabel.text = item.title
    }
    
}


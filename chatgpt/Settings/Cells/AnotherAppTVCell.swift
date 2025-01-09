//
//  AnotherAppTVCell.swift
//  chatgpt
//
//  Created by Yuriy on 02.01.2025.
//

import UIKit

final class AnotherAppTVCell: UITableViewCell {
    
    // MARK: - Properties

    static let identifier = String(describing: AnotherAppTVCell.self)
    
    private let backgroundContainer: UIView = {
        let backgroundContainer = UIView()
        backgroundContainer.backgroundColor = .clear
        backgroundContainer.layer.cornerRadius = 16
        backgroundContainer.layer.borderWidth = 1
        backgroundContainer.layer.borderColor = UIColor.topStroke.cgColor
        backgroundContainer.layer.masksToBounds = true
        backgroundContainer.translatesAutoresizingMaskIntoConstraints = false
        return backgroundContainer
    }()
    
    private let logoImage: UIImageView = {
        let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        return logoImage
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .SFProText(weight: .semibold, size: 15)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.font = .SFProText(weight: .regular, size: 13)
        subtitleLabel.textColor = .textSecondary
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return subtitleLabel
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
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setupConstraints() {
        contentView.addSubview(backgroundContainer)
        
        backgroundContainer.addSubview(logoImage)
        backgroundContainer.addSubview(titleLabel)
        backgroundContainer.addSubview(subtitleLabel)
        backgroundContainer.addSubview(arrowImage)
        
        NSLayoutConstraint.activate([
            backgroundContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            backgroundContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backgroundContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            
            logoImage.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 16),
            logoImage.centerYAnchor.constraint(equalTo: backgroundContainer.centerYAnchor),
            logoImage.widthAnchor.constraint(equalToConstant: 60),
            logoImage.heightAnchor.constraint(equalToConstant: 60),

            
            titleLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 23),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 15),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            
            arrowImage.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor, constant: -10),
            arrowImage.centerYAnchor.constraint(equalTo: backgroundContainer.centerYAnchor),
            arrowImage.widthAnchor.constraint(equalToConstant: 24),
            arrowImage.heightAnchor.constraint(equalToConstant: 24),

        ])
    }

    // MARK: - Public Methods

    func configure(_ item: AnotherAppConfiguration) {
        self.logoImage.image = item.image
        self.titleLabel.text = item.title
        self.subtitleLabel.text = item.subtitle
    }
}

//
//  ChatHistoryTVCell.swift
//  chatgpt
//
//  Created by Yuriy on 30.12.2024.
//

import UIKit

final class ChatHistoryTVCell: UITableViewCell {
    
    // MARK: - Identifier
    
    static let identifier = String(describing: ChatHistoryTVCell.self)
    
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
    
    // MARK: - Private properties
    
    private let logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // MARK: - Private methods
    
    private func setupConstraints() {
        contentView.addSubview(logoImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            logoImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logoImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            logoImage.widthAnchor.constraint(equalToConstant: 32),
            logoImage.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 18),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 18),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
        ])
    }
    
    
    //MARK: - Public methods
    
    func configure(_ item: HistoryChatConfiguration) {
        self.logoImage.image = item.image
        self.titleLabel.text = item.title
        self.subtitleLabel.text = item.subtitle
    }
    
}

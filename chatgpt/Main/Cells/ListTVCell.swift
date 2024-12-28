//
//  ListTVCell.swift
//  chatgpt
//
//  Created by Yuriy on 28.12.2024.
//

import UIKit

final class ListTVCell: UITableViewCell {
    
    static let identifier = String(describing: ListTVCell.self)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        setupConstraints()
    }
    
    //MARK: - Private variables
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .SFProText(weight: .semibold, size: 17)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let subTitleLabel: UILabel = {
        let subTitleLabel = UILabel()
        subTitleLabel.font = .SFProText(weight: .regular, size: 15)
        subTitleLabel.textColor = .textSecondary
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return subTitleLabel
    }()
    
    private let chvronImageView: UIImageView = {
        let chvronImageView = UIImageView()
        chvronImageView.image = .chevroneRight
        chvronImageView.translatesAutoresizingMaskIntoConstraints = false
        return chvronImageView
    }()
    
    private let devider: UIView = {
        let devider = UIView()
        devider.backgroundColor = .topStroke
        devider.translatesAutoresizingMaskIntoConstraints = false
        return devider
    }()
    
    
    //MARK: - Private methods
    
    private func setupConstraints() {
        
        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(chvronImageView)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(devider)
        
        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            logoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 45),
            logoImageView.widthAnchor.constraint(equalToConstant: 45),
            
            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            subTitleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 12),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),

            chvronImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
            chvronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            devider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            devider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            devider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 83),
            devider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    
    //MARK: - Public methods
    
    func configure(_ items: CollectionCellConfig) {
        self.logoImageView.kf.setImage(with: items.imageAvatar)
        self.titleLabel.text = items.name
        self.subTitleLabel.text = items.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


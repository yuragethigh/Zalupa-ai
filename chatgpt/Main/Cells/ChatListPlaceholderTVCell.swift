//
//  ChatListPlaceholder.swift
//  chatgpt
//
//  Created by Yuriy on 27.12.2024.
//

import UIKit

final class ChatListPlaceholderTVCell: UITableViewCell {
    
    static let id = String(describing: ChatListPlaceholderTVCell.self)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupConstraints()
    }
    
    //MARK: - Private views
    
    private let image: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .empty
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Нет чатов с экспертами"
        titleLabel.font = .SFProText(weight: .semibold, size: 18)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let subTitleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "В вашем распоряжении много экспертов. Начните диалог с любым из них\nи создайте свою историю."
        titleLabel.font = .SFProText(weight: .regular, size: 16)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    
    //MARK: - Private methods
    
    private func setupConstraints() {
        addSubview(image)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: topAnchor),
            image.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            image.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            image.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
//            subTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


#if DEBUG
@available(iOS 17.0, *)
#Preview {
    ChatListPlaceholderTVCell()
}
#endif

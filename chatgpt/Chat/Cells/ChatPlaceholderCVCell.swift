//
//  ChatPlaceholderCVCell.swift
//  chatgpt
//
//  Created by Yuriy on 15.01.2025.
//

import UIKit

final class ChatPlaceholderCVCell: UICollectionViewCell {
    static let identifier = String(describing: ChatPlaceholderCVCell.self)
    
    let cellImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let cellLbl: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .SFProText(weight: .medium, size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .bg
        contentView.layer.cornerRadius = 18
        contentView.layer.borderColor = UIColor.topStroke.cgColor
        contentView.layer.borderWidth = 1

        
        contentView.addSubview(cellImage)
        NSLayoutConstraint.activate([
            cellImage.widthAnchor.constraint(equalToConstant: 18),
            cellImage.heightAnchor.constraint(equalToConstant: 18),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9),
        ])
        
        contentView.addSubview(cellLbl)
        NSLayoutConstraint.activate([
            cellLbl.leadingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 6),
            cellLbl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cellLbl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)

        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(_ item: MockData) {
        self.cellImage.image = item.image
        self.cellLbl.text = item.title
    }
    
}

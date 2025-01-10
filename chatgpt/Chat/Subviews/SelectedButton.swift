//
//  SelectedButton.swift
//  chatgpt
//
//  Created by Yuriy on 10.01.2025.
//

import UIKit

final class SelectedButton: UIButton {
    
    // MARK: - Properties
    
    var selectedImage: UIImage? {
        didSet {
            self.setImage(selectedImage, for: .normal)
        }
    }

    private let crossImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .crossField
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    //MARK: - Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 4
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    
    private func setupConstraints() {

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 60),
            widthAnchor.constraint(equalToConstant: 60)
        ])

        addSubview(crossImageView)

        NSLayoutConstraint.activate([
            crossImageView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            crossImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            crossImageView.widthAnchor.constraint(equalToConstant: 12),
            crossImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
}


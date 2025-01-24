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
        imageView.image = .closenav
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#535353").withAlphaComponent(0.32)
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
            heightAnchor.constraint(equalToConstant: 64),
            widthAnchor.constraint(equalToConstant: 64)
        ])

        addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            container.widthAnchor.constraint(equalToConstant: 16),
            container.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        container.addSubview(crossImageView)
        
        NSLayoutConstraint.activate([
            crossImageView.widthAnchor.constraint(equalToConstant: 12),
            crossImageView.heightAnchor.constraint(equalToConstant: 12),
            crossImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            crossImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
    }
    
}


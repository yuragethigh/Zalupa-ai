//
//  HorizontalCollectionViewCell.swift
//  chatgpt
//
//  Created by Yuriy on 26.12.2024.
//

import UIKit
import Kingfisher

final class HorizontalCollectionViewCell: UICollectionViewCell {
    
    static let id = String(describing: HorizontalCollectionViewCell.self)
    
    private let animatedImageView: AnimatedImageView = {
        let animatedImageView = AnimatedImageView()
        animatedImageView.contentMode = .scaleAspectFit
        animatedImageView.repeatCount = .once
        animatedImageView.backgroundColor = .alert
        animatedImageView.translatesAutoresizingMaskIntoConstraints = false
        return animatedImageView
    }()
    
    private let blobsImage: UIImageView = {
       let imageView = UIImageView()
        imageView.image = .chatBlobs
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .SFProText(weight: .regular, size: 13)
        label.textColor = .black
        label.numberOfLines = 0
        label.clipsToBounds = true
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .none
        contentView.clipsToBounds = false
        
        contentView.addSubview(animatedImageView)
        NSLayoutConstraint.activate([
            animatedImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            animatedImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -86 - 32),
            animatedImageView.heightAnchor.constraint(equalToConstant: 323),
            animatedImageView.widthAnchor.constraint(equalToConstant: 257)
        ])
        
        contentView.addSubview(blobsImage)
        NSLayoutConstraint.activate([
            //MARK: - 32 bottom padding
            blobsImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            blobsImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            blobsImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            blobsImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        blobsImage.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.bottomAnchor.constraint(equalTo: blobsImage.bottomAnchor, constant: -12),
            textLabel.leadingAnchor.constraint(equalTo: blobsImage.leadingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: blobsImage.trailingAnchor, constant: -10),
            textLabel.topAnchor.constraint(equalTo: blobsImage.topAnchor, constant: 24)
        ])
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Public methods
    
    func configure(assistant: AssistantsConfiguration, isCentered: Bool) {
        
        textLabel.text = assistant.description
        blobsImage.alpha = !isCentered ? 0 : 1
        textLabel.alpha = !isCentered ? 0 : 1
    }
    
    func stopAnimation() {
        animatedImageView.stopAnimating()
        UIView.animate(withDuration: 0.2) { [self] in
            blobsImage.alpha = 0
            textLabel.alpha = 0
        }
    }
    
    func startAnimation(with animation: URL?, isCentered: Bool) {
        self.animatedImageView.stopAnimating()
//        animatedImageView.kf.setImage(with: animation) { result in
//            isCentered ? self.animatedImageView.startAnimating() : self.animatedImageView.stopAnimating()
//        }
//        UIView.animate(withDuration: 0.2) { [self] in
            blobsImage.alpha = !isCentered ? 0 : 1
            textLabel.alpha = !isCentered ? 0 : 1
//        }
    }
}



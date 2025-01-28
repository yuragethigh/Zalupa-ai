//
//  UINavigationItem + Extension.swift
//  chatgpt
//
//  Created by Yuriy on 15.01.2025.
//

import UIKit
import Kingfisher

extension UINavigationItem {
    func setTitle(
        title: String,
        image: URL? = nil,
        backgroundColors: AssistantsColors? = nil,
        subtitle: String? = nil) {
            
        let one = UILabel()
        one.text = title
        one.font = .SFProText(weight: .semibold, size: 17)
        
        let two = UILabel()
        two.text = subtitle
        two.textColor = .textSecondary
        two.font = .SFProText(weight: .regular, size: 14)
        two.textAlignment = .center

        let stackView = UIStackView(arrangedSubviews: [one, two])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.alignment = .leading
        
        
        let outerStackView = UIStackView(arrangedSubviews: [stackView])
        outerStackView.axis = .horizontal
        outerStackView.spacing = 10
        outerStackView.alignment = .center
        
        if let image = image {
            
            let gradientImageView = ScaledHeightImageView()
            gradientImageView.contentMode = .scaleAspectFit
            gradientImageView.clipsToBounds = true
            
            if let colors = backgroundColors {
                gradientImageView.applyGradient(
                    isVertical: true, colorArray: [
                        UIColor.hex(colors.color1),
                        UIColor.hex(colors.color2)
                    ]
                )
            }
            
            gradientImageView.kf.setImage(with: image)
            
            gradientImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                gradientImageView.widthAnchor.constraint(equalToConstant: 30),
                gradientImageView.heightAnchor.constraint(equalToConstant: 30)
            ])
            
            outerStackView.insertArrangedSubview(gradientImageView, at: 0)
        }
        
        self.titleView = outerStackView
    }
}



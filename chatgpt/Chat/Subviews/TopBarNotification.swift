//
//  TopBarNotification.swift
//  chatgpt
//
//  Created by Yuriy on 27.01.2025.
//

import UIKit

final class TopBarNotification: UIView {
    
    //MARK: - Property
    
    private let barImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .outlineRounded
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Привет! Я — ИИ, не человек. Мои слова стоит рассматривать как вымысел, не нужно верить или использовать сказанное мной как совет."
        label.numberOfLines = 0
        label.textColor = .textSecondary
        label.font = .SFProText(weight: .regular, size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let devider: UIView = {
        let view = UIView()
        view.backgroundColor = .topStroke
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .bg
        
        NSLayoutConstraint.activate([
            barImageView.widthAnchor.constraint(equalToConstant: 18),
            barImageView.heightAnchor.constraint(equalToConstant: 18),
        ])
        
        stack.addArrangedSubview(barImageView)
        stack.addArrangedSubview(textLabel)
        
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        addSubview(devider)
        NSLayoutConstraint.activate([
            devider.heightAnchor.constraint(equalToConstant: 0.5),
            devider.leadingAnchor.constraint(equalTo: leadingAnchor),
            devider.trailingAnchor.constraint(equalTo: trailingAnchor),
            devider.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

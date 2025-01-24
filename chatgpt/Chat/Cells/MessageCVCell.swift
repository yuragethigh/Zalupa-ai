//
//  MessageCVCell.swift
//  chatgpt
//
//  Created by Yuriy on 22.01.2025.
//

import UIKit
import SwiftUI

final class MessageCVCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = String(describing: MessageCVCell.self)
    
    private let outerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let spacerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
//        view.setContentHuggingPriority(.required, for: .horizontal)
//        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let spacer2View: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
//        view.setContentHuggingPriority(.required, for: .horizontal)
//        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .fill
        return stack
    }()
    
    private let messageLabel: LabelWithPadding = {
        let label = LabelWithPadding()
        label.insets = .init(top: 14, left: 12, bottom: 14, right: 12)
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .SFProText(weight: .medium, size: 15)
        label.layer.cornerRadius = 18
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .SFProText(weight: .regular, size: 13)
        label.textColor = .textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let timeImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    let maxWidth = UIScreen.main.bounds.width - 40
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        print("Max w - ", maxWidth)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        newFrame.size.height = ceil(size.height)
        newFrame.size.width = maxWidth
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageLabel.text = nil
        timeLabel.text = nil
        messageImageView.image = nil
        
        
        outerStackView.removeAllArrangedSubviews()
        timeStack.removeAllArrangedSubviews()
        mainStackView.removeAllArrangedSubviews()
    }

    
    // MARK: - Public methods
    
    func configure(with message: MessageConfiguration) {
        
        timeImageView.image = message.messageType == .user ? .checkUser : .checkAi
        timeLabel.text = message.sendingTime
        
        setupMessageImageView(message: message)
        
        setupText(message: message)
        
        setupCorners(message: message)
        
        if message.messageType == .user {
            mainStackView.alignment = .trailing
            outerStackView.addArrangedSubview(spacerView)
            outerStackView.addArrangedSubview(mainStackView)
            
            timeStack.addArrangedSubview(spacer2View)
            timeStack.addArrangedSubview(timeLabel)
            timeStack.addArrangedSubview(timeImageView)
        } else {
            outerStackView.addArrangedSubview(mainStackView)
            outerStackView.addArrangedSubview(spacerView)
            
            timeStack.addArrangedSubview(timeLabel)
            timeStack.addArrangedSubview(timeImageView)
            timeStack.addArrangedSubview(spacer2View)
        }
    }

    
    // MARK: - Private methods
    
    private func setupConstraints() {
        contentView.addSubview(outerStackView)
        
        NSLayoutConstraint.activate([
            outerStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            outerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            outerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        contentView.addSubview(timeStack)
        
        NSLayoutConstraint.activate([
            timeStack.topAnchor.constraint(equalTo: outerStackView.bottomAnchor, constant: 4),
            timeStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            timeStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            timeStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),            
        ])
    }
    
    private let messageImageView: UIImageView = {
       let imageview = UIImageView()
//        imageview.contentMode = .center
        imageview.backgroundColor = .red
        imageview.layer.cornerRadius = 14
        imageview.clipsToBounds = true
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()

    
    private func setupMessageImageView(message: MessageConfiguration) {
        guard let image = message.image else { return }
        messageImageView.image = image
        mainStackView.addArrangedSubview(messageImageView)
        NSLayoutConstraint.activate([
            messageImageView.widthAnchor.constraint(equalToConstant: 160),
            messageImageView.heightAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    
    private func setupCorners(message: MessageConfiguration) {
        let maskedCorners: CACornerMask = message.messageType == .user
            ? [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
            : [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        messageLabel.layer.maskedCorners = maskedCorners
       
    }
    
    private func setupText(message: MessageConfiguration) {
        if let text = message.text, !text.isEmpty {
            messageLabel.text = text
            messageLabel.backgroundColor = message.messageType == .user ? .lightAccent : .card
            mainStackView.addArrangedSubview(messageLabel)
        } else {
            messageLabel.text = nil
        }
    }
}

struct ImageSUI: View {
    let image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .clipped()
    }
}


//#if DEBUG
//@available(iOS 17.0, *)
//#Preview {
//    UINavigationController(
//        rootViewController: TestVC()
//    )
//}
//#endif
extension UIImageView {
    var contentClippingRect: CGRect {
    guard let image = image else { return bounds }
    guard contentMode == .scaleAspectFit else { return bounds }
    guard image.size.width > 0 && image.size.height > 0 else { return bounds }

    let scale: CGFloat
    if image.size.width > image.size.height {
        scale = bounds.width / image.size.width
    } else {
        scale = bounds.height / image.size.height
    }

    let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
    let x = (bounds.width - size.width) / 2.0
    let y = (bounds.height - size.height) / 2.0
    //print ("image resizing[width=\(size.width), height=\(size.height)")
    return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}

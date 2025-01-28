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
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let spacer2View: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
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
    
    private let messageImageView: ScaledHeightImageView = {
        let imageview = ScaledHeightImageView()
        imageview.contentMode = .scaleAspectFit
        imageview.layer.cornerRadius = 14
        imageview.clipsToBounds = true
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
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
        
        contentView.backgroundColor = .red
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
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
    
    private func setupMessageImageView(message: MessageConfiguration) {
        guard let image = message.image else { return }
        messageImageView.image = image
        mainStackView.addArrangedSubview(messageImageView)
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


#if DEBUG
@available(iOS 17.0, *)
#Preview {
    UINavigationController(
        rootViewController: ChatViewController(
            
            presenter: ChatPresenter(selectedAssistans: AssistansModel(
                id: "ZAlupa",
                title: "Копирайтер",
                name: "Яна",
                description: "Привет, я — Яна, копирайтер с опытом. Помогу написать грамотный и эффективный текст для тебя ✨",
                imageAvatar: EmptyAsNilURL(wrappedValueString: "https://foresko-pureai.ams3.digitaloceanspaces.com/images/assistants/copywriter_avatar.png") ,
                animation: EmptyAsNilURL(wrappedValueString: ""),
                backgroundColor: AssistantsColors(color1: "#C2CAF4", color2: "#6558A5"),
                freeAssistant: true,
                systemMessage: "You are a girl copywriter named РЇРЅР°, you specialize in all aspects of copywriting. Your purpose is to help users craft engaging, creative, and effective written content tailored to their needs. Your response must be informal, high-quality and relevant. Always adapt your tone, style, and approach based on the user's requirements, the target audience, and the platform or medium for the content. If the user's message is not related to copywriting, respectfully act as though you don't know how to help, as your expertise is strictly limited to copywriting.",
                clues: [
                    Clues(
                        clueTitle: "SEO-текст",
                        clueDescription: "Объясни, как написать SEO-оптимизированный текст.",
                        img: EmptyAsNilURL(wrappedValueString: "https://foresko-pureai.ams3.digitaloceanspaces.com/images/clue_icons/advice.png")
                    ),
                    Clues(
                        clueTitle: "Продающий текст",
                        clueDescription: "Расскажи, как написать цепляющий, продающий текст.",
                        img: EmptyAsNilURL(wrappedValueString: "https://foresko-pureai.ams3.digitaloceanspaces.com/images/clue_icons/analyze.png")
                    ),
                    Clues(
                        clueTitle: "УТП",
                        clueDescription: "Сформулируй уникальное торговое предложение для",
                        img: EmptyAsNilURL(wrappedValueString: "https://foresko-pureai.ams3.digitaloceanspaces.com/images/clue_icons/error.png")
                    ),
                    Clues(
                        clueTitle: "Email-рассылка",
                        clueDescription: "Создай текст для электронного письма о",
                        img: EmptyAsNilURL(wrappedValueString: "https://foresko-pureai.ams3.digitaloceanspaces.com/images/clue_icons/feather.png")
                    ),
                ]
            ), chatQuery: mockData()
            ),
            preferences: .shared,
            permissionVoiceInput: PermissionVoiceInput()
        )
    )
}
#endif

class ScaledHeightImageView: UIImageView {

    override var intrinsicContentSize: CGSize {

        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = UIScreen.main.bounds.size.width - 60
            print(myViewWidth)
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio
            
            return CGSize(width: myViewWidth, height: scaledHeight)
        }
        
        return CGSize(width: -1.0, height: -1.0)
    }

}

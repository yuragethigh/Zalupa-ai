//
//  FlexibleTextView.swift
//  chatgpt
//
//  Created by Yuriy on 06.01.2025.
//

import UIKit

final class FlexibleTextView: UITextView {
    
    // MARK: - Properties
    
    var maxHeight: CGFloat = 0
    
    private let placeholderTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.textColor = .white.withAlphaComponent(0.32)
        tv.font = .SFProText(weight: .regular, size: 15)
        tv.textContainerInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        return tv
    }()
    
    var placeholder: String? {
        get { placeholderTextView.text }
        set { placeholderTextView.text = newValue }
    }
    
    //MARK: - Initializers
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        setupObserver()
        
        setupTextView()
       
        setupPlaceholderTVConstraints()
    }

    deinit {
        removeObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Overrides
    
    override var text: String? {
        didSet {
            invalidateIntrinsicContentSize()
            if let text {
                placeholderTextView.isHidden = !text.isEmpty
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        
        if size.height == UIView.noIntrinsicMetric {
            layoutManager.glyphRange(for: textContainer)
            size.height = layoutManager.usedRect(for: textContainer).height
            + textContainerInset.top
            + textContainerInset.bottom
        }
        
        if maxHeight > 0.0 && size.height > maxHeight {
            size.height = maxHeight
            if !isScrollEnabled {
                isScrollEnabled = true
            }
        } else if isScrollEnabled {
            isScrollEnabled = false
        }
        return size
    }
    
    //MARK: - Private methods
    
    @objc private func textDidChange(_ note: Notification) {
        invalidateIntrinsicContentSize()
        if let text {
            placeholderTextView.isHidden = !text.isEmpty
        }
    }
}


//MARK: - FlexibleTextView + Extension


private extension FlexibleTextView {
    private func setupPlaceholderTVConstraints() {
        addSubview(placeholderTextView)
        
        NSLayoutConstraint.activate([
            placeholderTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeholderTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            placeholderTextView.topAnchor.constraint(equalTo: topAnchor),
            placeholderTextView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

private extension FlexibleTextView {
    private func setupTextView() {
        isScrollEnabled = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .textfield
        textContainerInset = placeholderTextView.textContainerInset
        font = placeholderTextView.font
    }
}


private extension FlexibleTextView {
    private func setupObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self)
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

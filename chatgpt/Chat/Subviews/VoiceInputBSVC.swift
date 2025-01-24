//
//  VoiceInputBSVC.swift
//  chatgpt
//
//  Created by Yuriy on 20.01.2025.
//

import UIKit
import Combine
import Lottie

protocol VoiceInputDelegate: AnyObject {
    func voiceInputDidFinish(_ text: String)
}

final class VoiceInputBSVC: BottomSheetController {
    
    // MARK: - Properties
    
    private lazy var closeButton: ButtonWithTouchSize = {
        let button = ButtonWithTouchSize()
        button.setImage(.closenav, for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let recognizedTextLabel: UILabel = {
        let label = UILabel()
        label.font = .SFProText(weight: .regular, size: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let animationView: LottieAnimationView = {
        let animation = LottieAnimationView(name: "Voice_GPT")
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.translatesAutoresizingMaskIntoConstraints = false
        return animation
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(VoiceInputLocs.done, for: .normal)
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @Published private var recognizedText: String?
    
    private var cancellabels = Set<AnyCancellable>()
    
    private let voiceInputService: VoiceInputService
    
    weak var voiceInputDelegate: VoiceInputDelegate?
    
    // MARK: - Initializers
    
    init(voiceInputService: VoiceInputService) {
        self.voiceInputService = voiceInputService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
#if DEBUG
    deinit {
        print("✅ deinit - VoiceInputBSVC")
    }
#endif
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .alert
        
        setupCloseButtonConstraints()
        
        setupDoneButtonConstraints()
        
        setupAnimationViewConstraints()
        
        setupRecognizedTextLabelConstraints()
                
        setupBindings()
        
        animationView.play()
    }
    
    // MARK: - Private methods
    
    private func setupCloseButtonConstraints() {
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupRecognizedTextLabelConstraints() {
        view.addSubview(recognizedTextLabel)
        NSLayoutConstraint.activate([
            recognizedTextLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            recognizedTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recognizedTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recognizedTextLabel.bottomAnchor.constraint(equalTo: animationView.topAnchor, constant: -20)
        ])
    }
    
    private func setupAnimationViewConstraints() {
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            animationView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -20)
        ])
    }
    
    private func setupDoneButtonConstraints() {
        view.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 54),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22)
        ])
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    @objc private func doneButtonTapped() {
        dismiss(animated: true)
        if let recognizedText {
            voiceInputDelegate?.voiceInputDidFinish(recognizedText)
        }
    }
    
    private func updateTextLabel(_ newValue: String?) {
        if newValue == nil {
            recognizedTextLabel.text = VoiceInputLocs.writing
            recognizedTextLabel.textColor = .textSecondary
        } else {
            recognizedTextLabel.text = newValue
            recognizedTextLabel.textColor = .white
        }
    }
    
    private func updateDoneButton(_ newValue: String?) {
        if newValue == nil {
            doneButton.setTitleColor(.textSecondary, for: .normal)
            doneButton.backgroundColor = .bgUnactive
        } else {
            doneButton.setTitleColor(.white, for: .normal)
            doneButton.backgroundColor = .mainAccent
        }
    }
    
    private func setupBindings() {
        
        voiceInputService.startRecognition { [weak self] newValue in
            guard let self else { return }
            recognizedText = newValue
        }
        
        $recognizedText.receive(on: DispatchQueue.main).sink { [weak self] newValue in
            guard let self else { return }
            updateTextLabel(newValue)
            updateDoneButton(newValue)
            view.layoutIfNeeded()
        }.store(in: &cancellabels)
    }
}

struct VoiceInputLocs {
    static let done = "Готово"
    static let writing = "Записываем..."
}


#if DEBUG
@available(iOS 17.0, *)
#Preview {
    VoiceInputBSVC(voiceInputService: VoiceInputService())
}
#endif

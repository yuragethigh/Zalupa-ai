//
//  ChatViewController.swift
//  chatgpt
//
//  Created by Yuriy on 27.12.2024.
//

import UIKit
import Combine


final class ChatPresenter {
    weak var vc: ChatViewController?
    
    var chatQuery: ChatQuery
    var selectedAssistans: AssistantsConfiguration
    
    init(selectedAssistans: AssistantsConfiguration, chatQuery: ChatQuery) {
        self.selectedAssistans = selectedAssistans
        self.chatQuery = chatQuery
       
    }
    
    let mockResponse = [
        "Это", " первое", " предложение.",
        " Вот", " второе", " предложение.",
        " Здесь", " идёт", " третье", " предложение.",
        " И наконец", " четвёртое", " предложение."
    ]

    
    func updateLastMessage(with newText: String) {
        guard
            let vc = vc,
            let lastDayIndex = chatQuery.daySection.indices.last,
            let lastMessageIndex = chatQuery.daySection[lastDayIndex].messages.indices.last
        else {
            return
        }
        
        chatQuery.daySection[lastDayIndex].messages[lastMessageIndex].text = (chatQuery.daySection[lastDayIndex].messages[lastMessageIndex].text ?? "") + newText
        
        vc.reloadItem(lastDayIndex: lastDayIndex, lastMessageIndex: lastMessageIndex)
    }
    
    func configure(_ viewController: ChatViewController) {
        self.vc = viewController
    }
}



final class ChatViewController: UIViewController {
    
    // MARK: - Properties

    private let placeholderCV = PlaceholderCollectionView()
    
    lazy var messageCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        collectionView.contentInset.top = 61
        collectionView.isPrefetchingEnabled = false
        collectionView.register(
            MessageCVCell.self,
            forCellWithReuseIdentifier: MessageCVCell.identifier
        )
        collectionView.register(
            HeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderView.identifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let copyBadge: CopyBadge = {
        let view = CopyBadge()
        view.text = "Текст скопирован"
        return view
    }()
    
    private let bottomInputView: BottomInputView = {
        let bottomInputView = BottomInputView()
        return bottomInputView
    }()
    
    private let keyboardManager = KeyboardManager()
    
    private let imagePicker = ImagePicker()
    
    private let topBarNotificationView = TopBarNotification()
        
    private var isNearBottom = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let preferences: Preferences
    
    private let permissionVoiceInput: PermissionVoiceInput
    
    private let presenter: ChatPresenter
    
    private var keyboardHeight: CGFloat = .zero

    // MARK: - Initializers
    
    init(
        presenter: ChatPresenter,
        preferences: Preferences,
        permissionVoiceInput: PermissionVoiceInput
    ) {
        self.presenter = presenter
        self.preferences = preferences
        self.permissionVoiceInput = permissionVoiceInput
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("✅ deinit - ChatViewController")
        removeObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setColor(backgroud: .bg, hideLine: true)
        navigationItem.setTitle(
            title: presenter.selectedAssistans.title,
            image: presenter.selectedAssistans.imageAvatar,
            backgroundColors: presenter.selectedAssistans.backgroundColor
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: .closenav, target: self, action: #selector(close)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .settingsChat, target: self, action: #selector(rightBarButtonTapped))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bg
        
        presenter.configure(self)
        
        placeholderCV.configure(clues: presenter.selectedAssistans.clues)
        
        setupMessageCVConstraints()
        
        setupPlaceholderCVConstraints()
        
        setupBottomInputViewConstraints()
        
        setupNotificationBarConstraints()
        
        setupCopyBadgeConstraints()
        
        updateCollectionViewVisibility()
        
        setupDelegates()
        
        setupBindings()
        
//        bottomInputView.textFieldBecomeFirstResponder()
       
    }
        
    // MARK: - Private methods
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
           keyboardFrame.cgRectValue.height > bottomInputView.bottomViewHeight {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            self.keyboardHeight = keyboardHeight
            adjustTableBottomInset(with: keyboardHeight + bottomInputView.bottomViewHeight)
            scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        adjustTableBottomInset(with: bottomInputView.frame.height )
        keyboardHeight = 0
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    @objc private func rightBarButtonTapped() {
        
    }
    
    private func adjustTableBottomInset(with keyboardHeight: CGFloat) {
        let additionalInset: CGFloat = 40
        messageCV.contentInset.bottom = (additionalInset + keyboardHeight)
    }
    
    private func updateCollectionViewVisibility() {
        placeholderCV.isHidden = !presenter.chatQuery.daySection.isEmpty
    }
    
    private func presentVoiceInputVC() {
        let voiceInputService = VoiceInputService()
        let vc = VoiceInputBSVC(voiceInputService: voiceInputService)
        vc.preferredSheetSizing = .fit
        vc.voiceInputDelegate = self
        present(vc, animated: true)
    }
    
    private func alertVoicePermission() {
        let alert = UIAlertController.create(
            title: "Требуется доступ к Микрофону",
            message: "Это нужно для того, чтобы специалисты понимали вас и могли отвечать.",
            preferredStyle: .alert,
            actions: (title: "Отмена", style: .cancel, handler: nil),
            (title: "Настройки", style: .default, handler: { _ in
                Deeplinks.open(type: .appSettings)
            })
        )
        present(alert, animated: true)
    }
}


extension ChatViewController: ChatPlaceholderDelegate {
    func didSelectItem(from item: Clues) {
        bottomInputView.updateField(item.clueDescription)
    }
}

extension ChatViewController: VoiceInputDelegate {
    func voiceInputDidFinish(_ text: String) {
        bottomInputView.updateField(text)
    }
}


// MARK: - ImagePickerDelegate

extension ChatViewController: ImagePickerDelegate {
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage) {
        imagePicker.dismiss()
        bottomInputView.configureSelectImageButton(with: image)
    }
    
    func cancelButtonDidClick(on imagePicker: ImagePicker) {
        imagePicker.dismiss()

    }
}

extension ChatViewController {
    func insertItem(for message: MessageModel, scrollToBottom: Bool = false) {
        let todayKey = getCurrentDateString()
        
        if let index = presenter.chatQuery.daySection.firstIndex(where: { getDateString(from: $0.date) == todayKey }) {
            presenter.chatQuery.daySection[index].messages.append(message)
            messageCV.performBatchUpdates( {
                // Вставка элемента в массив с сообщениями если дата равна сегодняшней
                let indexPath = IndexPath(row: presenter.chatQuery.daySection[index].messages.count - 1, section: index)
                messageCV.insertItems(at: [indexPath])
            }, completion: {_ in
                guard scrollToBottom else { return }
                
                self.scrollToBottom()
            })
        } else {
            // Вставка секции + сообщения
            let newSection = DaySection(date: Date(), messages: [message])
            presenter.chatQuery.daySection.append(newSection)
            
            messageCV.performBatchUpdates( {
                let sectionIndex = presenter.chatQuery.daySection.count - 1
                let indexPath = IndexSet(integer: sectionIndex)
                self.messageCV.insertSections(indexPath)
            }, completion: {_ in
                guard scrollToBottom else { return }
                
                self.scrollToBottom()
            })
        }
    }
    
    func load() {
        guard
              let lastDayIndex = presenter.chatQuery.daySection.indices.last,
              let lastMessageIndex = presenter.chatQuery.daySection[lastDayIndex].messages.indices.last
        else { return }
        let indexPath = IndexPath(item: lastMessageIndex, section: lastDayIndex)
        messageCV.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }

    
    func scrollToBottom() {
        guard isNearBottom,
              let lastDayIndex = presenter.chatQuery.daySection.indices.last,
              let lastMessageIndex = presenter.chatQuery.daySection[lastDayIndex].messages.indices.last
        else { return }
        let indexPath = IndexPath(item: lastMessageIndex, section: lastDayIndex)
        messageCV.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }

    func reloadItem(lastDayIndex: Int, lastMessageIndex: Int) {
        let indexPath = IndexPath(item: lastMessageIndex , section: lastDayIndex)
        
        UIView.performWithoutAnimation {
            messageCV.performBatchUpdates({
                messageCV.reloadItems(at: [indexPath])
            }) { _ in
                self.messageCV.collectionViewLayout.invalidateLayout()
            }
        }
    }

    
    func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: Date())
    }
    
    func getDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
}

// MARK: - BottomInputDelegate

extension ChatViewController: BottomInputDelegate {
    func stopGenerateAction() {
        bottomInputView.stopGenerate()
    }
    
    func sendButtonAction(_ text: String?, _ image: UIImage?) {
        
        let message = MessageModel(text: text, image: image, messageType: .user)
        insertItem(for: message, scrollToBottom: true)
        updateCollectionViewVisibility()
        mockResponse()
    }
    
    func mockResponse() {
        let message = MessageModel(text: "", image: nil, messageType: .ai)
        insertItem(for: message, scrollToBottom: true)
        
        var delay: TimeInterval = 1
        for sentencePart in presenter.mockResponse {
           
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard self.bottomInputView.generateIsActive else {
                    return
                }
                self.presenter.updateLastMessage(with: sentencePart)
            }
            delay += 0.5
        }
        
    }
    
    func requestMicPermissionAction() {
        permissionVoiceInput.checkPermission { [weak self] isGranted in
            guard let self else { return }
            preferences.micPerission = isGranted
            DispatchQueue.main.async {
                isGranted ? self.presentVoiceInputVC() : self.alertVoicePermission()
            }
        }
    }
    
    func presentBottomSheetAction() {
        presentVoiceInputVC()
    }
    
    func addImageButtonAction() {
        let alert = UIAlertController.create(
            title: "Добавить фото",
            message: nil,
            preferredStyle: .actionSheet,
            actions: (title: "Открыть камеру", style: .default, handler: { [weak self] _ in
                guard let self else { return }
                imagePicker.present(from: self, sourceType: .camera)
            }),
            (title: "Выбрать из галереи", style: .default, handler: { [weak self] _ in
                guard let self else { return }
                imagePicker.present(from: self, sourceType: .photoLibrary)
            }),
            (title: "Отмена", style: .cancel, handler: nil)
        )
        
        present(alert, animated: true)
    }
}



// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension ChatViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter.chatQuery.daySection.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        presenter.chatQuery.daySection[section].messages.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MessageCVCell.identifier,
            for: indexPath
        ) as? MessageCVCell else {
            return UICollectionViewCell()
        }
        let section = presenter.chatQuery.daySection[indexPath.section]
        let message = section.messages[indexPath.item]
        cell.configure(with: message)
        return cell
        
    }
    
    //MARK: - Header
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HeaderView.identifier,
            for: indexPath
        ) as? HeaderView else {
            return UICollectionReusableView()
        }
        let currentDay = getCurrentDateString()
        let section = presenter.chatQuery.daySection[indexPath.section]
        let todayDateString = getDateString(from: section.date)
        let returnedDay = currentDay == todayDateString ? "Сегодня" : todayDateString
        headerView.titleLabel.text = returnedDay
        return headerView
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 48)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height

        isNearBottom = offsetY >= contentHeight - scrollViewHeight - 20
        
    }
}

// MARK: - UIContextMenuConfiguration

extension ChatViewController {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        let section = presenter.chatQuery.daySection[indexPath.section]
        let message = section.messages[indexPath.item]

        return UIContextMenuConfiguration(identifier: indexPath as NSCopying,
                                          previewProvider: nil) { _ in
            let shareAction = UIAction(
                title: "Копировать",
                image: .answer
            ) { [weak self] _ in
                UIPasteboard.general.string = message.text
                self?.copyBadge.animate()
            }
            
            let editAction = UIAction(
                title: "Поделиться",
                image: .share
            ) { _ in
                UIActivityViewController.present(
                    viewController: self,
                    activityItems: [message.text ?? "", message.image as Any]
                )
            }
            
            return UIMenu(title: "", children: [shareAction, editAction])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath) as? MessageCVCell
        else {
            return nil
        }
        
        bottomInputView.textFieldResignFirstResponder()
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        let targetedPreview = UITargetedPreview(view: cell.mainStackView, parameters: parameters)
        return targetedPreview
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath) as? MessageCVCell
        else {
            return nil
        }
        
        bottomInputView.textFieldResignFirstResponder()
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        let targetedPreview = UITargetedPreview(view: cell.mainStackView, parameters: parameters)
        return targetedPreview
    }
}

// MARK: - Constraints

private extension ChatViewController {
    
    private func setupMessageCVConstraints() {
        view.addSubview(messageCV)
        NSLayoutConstraint.activate([
            messageCV.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            messageCV.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageCV.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageCV.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupPlaceholderCVConstraints() {
        view.addSubview(placeholderCV)
        NSLayoutConstraint.activate([
            placeholderCV.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 84 + 61),
            placeholderCV.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 29),
            placeholderCV.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -29),
            placeholderCV.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupBottomInputViewConstraints() {
        view.addSubview(bottomInputView)
        keyboardManager.bind(inputAccessoryView: bottomInputView, withAdditionalBottomSpace: {
            return -self.view.safeAreaInsets.bottom
        })
        keyboardManager.bind(inputAccessoryView: bottomInputView)
        keyboardManager.bind(to: messageCV)
    }
    
    private func setupNotificationBarConstraints() {
        view.addSubview(topBarNotificationView)
        NSLayoutConstraint.activate([
            topBarNotificationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarNotificationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarNotificationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupCopyBadgeConstraints() {
        view.addSubview(copyBadge)
        NSLayoutConstraint.activate([
            copyBadge.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            copyBadge.heightAnchor.constraint(equalToConstant: 36),
            copyBadge.widthAnchor.constraint(equalToConstant: 168),
            copyBadge.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - Delegates

extension ChatViewController {
    
    func setupDelegates() {
        messageCV.delegate = self
        messageCV.dataSource = self
        
        bottomInputView.bottomInputDelegate = self
        imagePicker.delegate = self
        placeholderCV.chatPlaceholderDelegate = self
    }
}

//MARK: - Bindings

private extension ChatViewController {
    private func setupBindings() {
        bottomInputView.$bottomViewHeight
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self else { return }
                adjustTableBottomInset(with: newValue + keyboardHeight)
//                scrollToBottom()
            }
            .store(in: &cancellables)
        
        preferences.$micPerission
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.bottomInputView.updateMicPermission(newValue)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeObservers() {
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


func mockData() -> ChatQuery {

    return ChatQuery(
        id: "ZALUPA",
        daySection: [
            DaySection(
                date: Date().addingTimeInterval(-3 * 86400),
                messages: [
                    MessageModel(text: "MOCK - \nMessage 1", image: .test, messageType: .user),
                    MessageModel(text: "MOCK - \nMessage 2", image: nil, messageType: .ai)
                ]
            ),
            DaySection(
                date: Date().addingTimeInterval(-86400),
                messages: [
                    MessageModel(text: "MOCK - \nMessage 3", image: nil, messageType: .ai),
                    MessageModel(text: "MOCK - \nMessage 3", image: nil, messageType: .user),
                    MessageModel(text: "MOCK - \nMessage 3", image: nil, messageType: .ai),
                    MessageModel(text: "MOCK - \nMessage 3", image: nil, messageType: .user),
                    MessageModel(text: "MOCK - \nMessage 3", image: nil, messageType: .ai),
                    MessageModel(text: "MOCK - \nMessage 3", image: nil, messageType: .user),
                    MessageModel(text: "MOCK - \nMessage 3", image: nil, messageType: .ai),
                    MessageModel(text: "MOCK - \nMessage 3", image: nil, messageType: .user),
                    MessageModel(text: "MOCK - \nMessage 3", image: nil, messageType: .ai),
                    MessageModel(text: "MOCK - \nMessage 3", image: nil, messageType: .user),
                    MessageModel(text: "MOCK - \nMessage 3", image: nil, messageType: .ai),
                    MessageModel(text: "MOCK - \nMessage 3", image: nil, messageType: .user),
                ]
            ),
        ]
    )
}



final class BottomInputView: UIView {
    
    // MARK: - Properties

    private let devider: UIView = {
        let view = UIView()
        view.backgroundColor = .topStroke
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let flexibleBG: UIView = {
        let view = UIView()
        view.backgroundColor = .textfield
        view.layer.cornerRadius = 14
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textField: FlexibleTextView = {
        let textField = FlexibleTextView()
        textField.placeholder = "Задай свой вопрос..."
        textField.maxHeight = 180
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var textFieldDeleteButton: UIButton = {
        let button = UIButton()
        button.setImage(.crossField, for: .normal)
        button.addTarget(self, action: #selector(crossButtonIsTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private lazy var addImageButton: ButtonWithTouchSize = {
        let button = ButtonWithTouchSize()
        button.setImage(.imgField, for: .normal)
        button.touchAreaPadding = .init(top: 10, left: 10, bottom: 10, right: 10)
        button.addTarget(self, action: #selector(addImageButtonIsTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(sendButtonIsTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var selectImageButton: SelectedButton = {
        let button = SelectedButton()
        button.addTarget(self, action: #selector(imageButtonIsTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var horizontalStack: UIStackView = {
        let spacer = UIView()
        spacer.isUserInteractionEnabled = false
        spacer.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        spacer.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [selectImageButton, spacer])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var verticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textField])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 7
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    weak var bottomInputDelegate: BottomInputDelegate?
    
    private var selectedImage: UIImage? {
        didSet {
            updateSendButtonState()
        }
    }
    
    private var micPermission: Bool = false
    var generateIsActive: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var buttonState: SendButtonState = .openBottomSheet
    
    //MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleHeight
        backgroundColor = .card
        
        setupAddImageConstraints()
        
        setupSendButtonConstraints()
        
        setupFlexibleBGConstraints()
        
        setupVerticalStackConstraints()
        
        setupTextFieldDeleteButtonConstraints()
        
        setupDeviderConstraints()
        
        setupBindings()

    }
    
    deinit {
        removeObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Overrides
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    @Published var bottomViewHeight: CGFloat = .zero
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let newHeight = bounds.height
        bottomViewHeight = newHeight
    }
    
    //MARK: - Private methods
    
    @objc private func sendButtonIsTapped() {

        switch buttonState {
        case .requestMicPermission:
            bottomInputDelegate?.requestMicPermissionAction()
        case .openBottomSheet:
            bottomInputDelegate?.presentBottomSheetAction()
        case .send:
            generateIsActive = true
            bottomInputDelegate?.sendButtonAction(textField.text, selectedImage)
            updateField()
            removeSelectedImage()
            
        case .stop:
            bottomInputDelegate?.stopGenerateAction()
        }
    }
    
    @objc private func addImageButtonIsTapped() {
        bottomInputDelegate?.addImageButtonAction()
    }
    
    @objc private func crossButtonIsTapped() {
        updateField()
    }
    
    @objc private func textDidChange(_ note: Notification) {
        updateSendButtonState()
    }
    
    @objc private func imageButtonIsTapped() {
        removeSelectedImage()
    }
    
    private func removeSelectedImage() {
        selectedImage = nil
        verticalStack.removeArrangedSubview(horizontalStack)
        horizontalStack.removeFromSuperview()
    }
    
    private func updateSendButtonState() {
        if generateIsActive {
            buttonState = .stop
            sendButton.setImage(buttonState.currentImage, for: .normal)
            textFieldDeleteButton.isHidden = generateIsActive
            
        } else if let text = textField.text, !text.isEmpty || selectedImage != nil {
            buttonState = .send
            textFieldDeleteButton.isHidden = text.isEmpty
            sendButton.setImage(buttonState.currentImage, for: .normal)
        } else if micPermission {
            buttonState = .openBottomSheet
            textFieldDeleteButton.isHidden = true
            sendButton.setImage(buttonState.currentImage, for: .normal)
        } else {
            buttonState = .requestMicPermission
            textFieldDeleteButton.isHidden = true
            sendButton.setImage(buttonState.currentImage, for: .normal)
            
        }
    }
    
    //MARK: - Public methods
    
    func updateMicPermission(_ newValue: Bool) {
        micPermission = newValue
        updateSendButtonState()
    }
    
    func configureSelectImageButton(with image: UIImage?) {

        selectImageButton.selectedImage = image
        selectedImage = image

        if !verticalStack.arrangedSubviews.contains(horizontalStack) {
            verticalStack.insertArrangedSubview(horizontalStack, at: 0)
        }
    }
    
    func stopGenerate() {
        generateIsActive = false
        updateSendButtonState()
    }
    
    func updateField(_ text: String = "") {
        textField.text = text
        NotificationCenter.default.post(
            name: UITextView.textDidChangeNotification,
            object: textField
        )
    }
    
    func textFieldBecomeFirstResponder() {
        textField.becomeFirstResponder()
    }
    
    func textFieldResignFirstResponder() {
        textField.resignFirstResponder()
    }
}


//MARK: - BottomInputView + Extension

private extension BottomInputView {
    func setupBindings() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: UITextView.textDidChangeNotification,
            object: textField
        )
    }
    
     func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension BottomInputView {
    
    
    func setupFlexibleBGConstraints() {
        addSubview(flexibleBG)
        NSLayoutConstraint.activate([
            flexibleBG.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            flexibleBG.leadingAnchor.constraint(equalTo: addImageButton.trailingAnchor, constant: 10),
            flexibleBG.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            flexibleBG.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])
    }
        
    func setupVerticalStackConstraints() {
        flexibleBG.addSubview(verticalStack)
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: flexibleBG.topAnchor, constant: 12),
            verticalStack.bottomAnchor.constraint(equalTo: flexibleBG.bottomAnchor, constant: -12),
            verticalStack.leadingAnchor.constraint(equalTo: flexibleBG.leadingAnchor, constant: 12),
            verticalStack.trailingAnchor.constraint(equalTo: flexibleBG.trailingAnchor, constant: -36),
            
        ])
    }
    
    private func setupTextFieldDeleteButtonConstraints() {
        addSubview(textFieldDeleteButton)
        NSLayoutConstraint.activate([
            textFieldDeleteButton.topAnchor.constraint(equalTo: textField.topAnchor),
            textFieldDeleteButton.trailingAnchor.constraint(equalTo: flexibleBG.trailingAnchor, constant: -12),
            textFieldDeleteButton.heightAnchor.constraint(equalToConstant: 24),
            textFieldDeleteButton.widthAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    private func setupAddImageConstraints() {
        addSubview(addImageButton)
        NSLayoutConstraint.activate([
            addImageButton.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            addImageButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            addImageButton.heightAnchor.constraint(equalToConstant: 24),
            addImageButton.widthAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    private func setupSendButtonConstraints() {
        addSubview(sendButton)
        NSLayoutConstraint.activate([
            sendButton.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            sendButton.widthAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func setupDeviderConstraints() {
        addSubview(devider)
        NSLayoutConstraint.activate([
            devider.topAnchor.constraint(equalTo: topAnchor),
            devider.leadingAnchor.constraint(equalTo: leadingAnchor),
            devider.trailingAnchor.constraint(equalTo: trailingAnchor),
            devider.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }
}


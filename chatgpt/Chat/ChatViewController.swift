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
    
    var sectionDays = [DaySection]()
    
    init() {
        sectionDays.append(DaySection(date: Date().addingTimeInterval(-3 * 86400), messages: [
            MessageModel(text: "Message 1 for 21st January", image: .test, messageType: .user)
        ]))
        
        sectionDays.append(DaySection(date: Date().addingTimeInterval(-86400), messages: [
            MessageModel(text: "Message 1 for yesterday", image: nil, messageType: .ai)
        ]))
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
            let lastDayIndex = sectionDays.indices.last,
            let lastMessageIndex = sectionDays[lastDayIndex].messages.indices.last
        else {
            return
        }
        
        sectionDays[lastDayIndex].messages[lastMessageIndex].text = (sectionDays[lastDayIndex].messages[lastMessageIndex].text ?? "") + newText
        
        vc.reloadItem(lastDayIndex: lastDayIndex, lastMessageIndex: lastMessageIndex)
    }
    
    func configure(_ viewController: ChatViewController) {
        self.vc = viewController
    }
}

final class ChatViewController: UIViewController {
    
    // MARK: - Properties
    
    @Published var data: [MockData] = [
        MockData(title: "Написать текст"),
        MockData(title: "Придумать"),
        MockData(title: "Проанализировать"),
        MockData(title: "Составить план"),
        MockData(title: "Получить совет")
    ]
    
//    private let placeholderCV: UICollectionView = {
//        let layout = CenteredFlowLayout()
//        layout.minimumInteritemSpacing = 14
//        layout.minimumLineSpacing = 18
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.backgroundColor = .clear
//        cv.translatesAutoresizingMaskIntoConstraints = false
//        cv.register(
//            ChatPlaceholderCVCell.self,
//            forCellWithReuseIdentifier: ChatPlaceholderCVCell.identifier
//        )
//        return cv
//    }()
    
    lazy var messageCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
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
    
    private let bottomInputView: BottomInputView = {
        let bottomInputView = BottomInputView()
        return bottomInputView
    }()
    
    private let keyboardManager = KeyboardManager()
    
    private let imagePicker = ImagePicker()
        
    private var isNearBottom = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let preferences: Preferences
    
    private let permissionVoiceInput: PermissionVoiceInput
    
    private let presenter = ChatPresenter()


    // MARK: - Initializers
    
    init(
        preferences: Preferences,
        permissionVoiceInput: PermissionVoiceInput
    ) {
        self.preferences = preferences
        self.permissionVoiceInput = permissionVoiceInput
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        removeObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setColor(backgroud: .bg, hideLine: false)
        navigationItem.setTitle(title: "Задание")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: .closenav, target: self, action: #selector(close)
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bg
        presenter.configure(self)
        
        setupTVConstraints()
        
//        setupCollectionViewConstraints()
        
//        updateCollectionViewVisibility()
        
        setupDelegates()
        
        setupBindings()
        
        setupBottomInputView()
        
        bottomInputView.textFieldBecomeFirstResponder()
        
        messageCV.reloadData()
    }
        
    // MARK: - Private methods
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
           keyboardFrame.cgRectValue.height > bottomInputView.bottomViewHeight {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            adjustTableBottomInset(with: keyboardHeight + bottomInputView.bottomViewHeight)
            scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        adjustTableBottomInset(with: bottomInputView.bottomViewHeight )
        scrollToBottom()
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    private func adjustTableBottomInset(with keyboardHeight: CGFloat) {
        let additionalInset: CGFloat = 40
        messageCV.contentInset.bottom = (additionalInset + keyboardHeight) - view.safeAreaInsets.bottom
    }
    
//    private func updateCollectionViewVisibility() {
//        placeholderCV.isHidden = !presenter.sectionDays.isEmpty
//    }
    
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
        
        if let index = presenter.sectionDays.firstIndex(where: { getDateString(from: $0.date) == todayKey }) {
            presenter.sectionDays[index].messages.append(message)
            messageCV.performBatchUpdates( {
                // Вставка элемента в массив с сообщениями если дата равна сегодняшней
                let indexPath = IndexPath(row: presenter.sectionDays[index].messages.count - 1, section: index)
                messageCV.insertItems(at: [indexPath])
            }, completion: {_ in
                guard scrollToBottom else { return }
                
                self.scrollToBottom()
            })
        } else {
            // Вставка секции + сообщения
            let newSection = DaySection(date: Date(), messages: [message])
            presenter.sectionDays.append(newSection)
            
            messageCV.performBatchUpdates( {
                let sectionIndex = presenter.sectionDays.count - 1
                let indexPath = IndexSet(integer: sectionIndex)
                self.messageCV.insertSections(indexPath)
            }, completion: {_ in
                guard scrollToBottom else { return }
                
                self.scrollToBottom()
            })
        }
    }

    
    func scrollToBottom() {
        guard isNearBottom,
              let lastDayIndex = presenter.sectionDays.indices.last,
              let lastMessageIndex = presenter.sectionDays[lastDayIndex].messages.indices.last
        else { return }
        let indexPath = IndexPath(item: lastMessageIndex, section: lastDayIndex)
        messageCV.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }

    func reloadItem(lastDayIndex: Int, lastMessageIndex: Int) {
        let indexPath = IndexPath(item: lastMessageIndex , section: lastDayIndex)
        messageCV.performBatchUpdates {
            messageCV.reloadItems(at: [indexPath])
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
//        updateCollectionViewVisibility()
        mockResponse()
    }
    
    func mockResponse() {
        let message = MessageModel(text: "", image: nil, messageType: .ai)
        insertItem(for: message, scrollToBottom: true)
        
        var delay: TimeInterval = 1
        for sentencePart in presenter.mockResponse {
           
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                print(sentencePart)
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
        return presenter.sectionDays.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        presenter.sectionDays[section].messages.count
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
        let section = presenter.sectionDays[indexPath.section]
        let message = section.messages[indexPath.item]
        cell.configure(with: message)
        addInteraction(toCell: cell.mainStackView)
        return cell
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//       
//            let selectedItem = data[indexPath.item]
//            bottomInputView.updateField(selectedItem.title)
//            print("Selected item: \(selectedItem.title)")
//
//    }
    
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
        let section = presenter.sectionDays[indexPath.section]
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

// MARK: - Constraints

private extension ChatViewController {
    
    private func setupTVConstraints() {
        view.addSubview(messageCV)
        NSLayoutConstraint.activate([
            messageCV.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            messageCV.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageCV.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageCV.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
//    private func setupCollectionViewConstraints() {
//        view.addSubview(placeholderCV)
//        NSLayoutConstraint.activate([
//            placeholderCV.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 84 + 61),
//            placeholderCV.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            placeholderCV.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            placeholderCV.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])
//    }
//    
    private func setupBottomInputView() {
        view.addSubview(bottomInputView)
        keyboardManager.bind(inputAccessoryView: bottomInputView, withAdditionalBottomSpace: {
            return -self.view.safeAreaInsets.bottom
        })
        keyboardManager.bind(inputAccessoryView: bottomInputView)
        keyboardManager.bind(to: messageCV)
    }
}

// MARK: - Delegates

private extension ChatViewController {
    private func setupDelegates() {
        messageCV.delegate = self
        messageCV.dataSource = self
        
//        placeholderCV.dataSource = self
//        placeholderCV.delegate = self
        
        bottomInputView.bottomInputDelegate = self
        imagePicker.delegate = self
    
    }
}

//MARK: - Bindings

private extension ChatViewController {
    private func setupBindings() {
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

// MARK: - UIContextMenuInteractionDelegate

extension ChatViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            let shareAction = UIAction(
                title: "Копировать",
                image: .answer
            ) { _ in
                
            }
            let editAction = UIAction(
                title: "Поделиться",
                image: .share
            ) { _ in
            }
            let deleteAction = UIAction(
                title: "Ответить",
                image: .forward
            ) { _ in
            }
            return UIMenu(title: "", children: [shareAction, editAction, deleteAction])
        }
    }
    
    private func addInteraction(toCell cell: UIView) {
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
    }
}


#if DEBUG
@available(iOS 17.0, *)
#Preview {
    UINavigationController(
        rootViewController: ChatViewController(
            preferences: .shared, permissionVoiceInput: PermissionVoiceInput()
        )
    )
}
#endif





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
    
    var bottomViewHeight: CGFloat = .zero
    
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



struct MockData {
    let image: UIImage = .write
    let title: String
}

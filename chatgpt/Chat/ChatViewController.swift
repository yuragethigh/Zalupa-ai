//
//  ChatViewController.swift
//  chatgpt
//
//  Created by Yuriy on 27.12.2024.
//

import UIKit
import Combine

final class ChatViewController: UIViewController {
    
    // MARK: - Properties
    var items = 29
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .interactive
//        tableView.contentInset.bottom = 34
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let keyboardManager = KeyboardManager()
    
    private let bottomInputView = BottomInputView()

    private let imagePicker = ImagePicker()
    
    private let preferences: Preferences
    
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers
    
    init(preferences: Preferences) {
        self.preferences = preferences
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bg
        
        setupTVConstraints()
        setupDelegates()
        setupBottomInputView()
            
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
        
        bottomInputView.textFieldBecomeFirstResponder()
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustTableBottomInset(with: 0)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            adjustTableBottomInset(with: keyboardHeight)
            tableView.scrollToRow(at: IndexPath(row: items - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    private func adjustTableBottomInset(with keyboardHeight: CGFloat) {
        let additionalInset: CGFloat = 0
        tableView.contentInset.bottom = (bottomInputView.bottomViewHeight + additionalInset + keyboardHeight) - view.safeAreaInsets.bottom
        tableView.verticalScrollIndicatorInsets.bottom = (bottomInputView.bottomViewHeight + additionalInset + keyboardHeight) - view.safeAreaInsets.bottom
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setColor(backgroud: .bg, hideLine: false)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: .closenav, target: self, action: #selector(close)
        )
    }
        
    // MARK: - Private methods
    
    @objc private func close() {
        dismiss(animated: true)
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

// MARK: - BottomInputDelegate

extension ChatViewController: BottomInputDelegate {
    
    func sendButtonAction(_ text: String?, _ image: UIImage?) {
        print("sendButtonAction")
        items += 1
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: items - 1, section: 0), at: .bottom, animated: false)
    }
    
    func requestMicPermissionAction() {
        print("requestMicPermissionAction")
        preferences.micPerission = true
    }
    
    func presentBottomSheetAction() {
        print("presentBottomSheetAction")
        preferences.micPerission = false
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

// MARK: - UITableViewDelegate / UITableViewDataSource

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = "Row: \(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bottomInputView.textField.text = "Row: \(indexPath.row)"
        NotificationCenter.default.post(
            name: UITextView.textDidChangeNotification,
            object: bottomInputView.textField
        )
    }
}

// MARK: - Constraints

private extension ChatViewController {
    
    private func setupTVConstraints() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupBottomInputView() {
        view.addSubview(bottomInputView)
        keyboardManager.bind(inputAccessoryView: bottomInputView, withAdditionalBottomSpace: {
            return -self.view.safeAreaInsets.bottom
        })
        keyboardManager.bind(inputAccessoryView: bottomInputView)
        keyboardManager.bind(to: tableView)
    }
}

// MARK: - Setup delegates

private extension ChatViewController {
    private func setupDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        bottomInputView.bottomInputDelegate = self
        imagePicker.delegate = self
    }
}



#if DEBUG
@available(iOS 17.0, *)
#Preview {
    UINavigationController(
        rootViewController: ChatViewController(preferences: .shared)
    )
}
#endif


protocol BottomInputDelegate: AnyObject {
    func sendButtonAction(_ text: String?, _ image: UIImage?)
    func requestMicPermissionAction()
    func presentBottomSheetAction()
    func addImageButtonAction()
}

enum SendButtonState {
    case requestMicPermission      // нет текста + micPermission = false
    case openBottomSheet           // нет текста + micPermission = true
    case send                      // есть текст (micPermission неважен)
    
    var currentImage: UIImage {
        switch self {
        case .requestMicPermission: .voiceNotAvailable
        case .openBottomSheet: .voice
        case .send: .send
        }
    }
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
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
    
    private lazy var addImageButton: UIButton = {
        let button = UIButton()
        button.setImage(.imgField, for: .normal)
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
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var buttonState: SendButtonState = .openBottomSheet

    
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
        print(newHeight)
    }
    
    //MARK: - Private methods
    
    @objc private func sendButtonIsTapped() {
        
        switch buttonState {
        case .requestMicPermission:
            bottomInputDelegate?.requestMicPermissionAction()
        case .openBottomSheet:
            bottomInputDelegate?.presentBottomSheetAction()
        case .send:
            bottomInputDelegate?.sendButtonAction(textField.text, selectedImage)
            clearTextField()
            removeSelectedImage()
        }
    }
    
    @objc private func addImageButtonIsTapped() {
        bottomInputDelegate?.addImageButtonAction()
    }
    
    @objc private func crossButtonIsTapped() {
        clearTextField()
    }
    
    @objc private func textDidChange(_ note: Notification) {
        updateSendButtonState()
    }
    
    @objc private func imageButtonIsTapped() {
        removeSelectedImage()
    }
    
    private func removeSelectedImage() {
        verticalStack.removeArrangedSubview(horizontalStack)
        horizontalStack.removeFromSuperview()
        selectedImage = nil
    }
    
    private func updateSendButtonState() {
        if let text = textField.text, !text.isEmpty || selectedImage != nil {
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
    
    func clearTextField() {
        textField.text = ""
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

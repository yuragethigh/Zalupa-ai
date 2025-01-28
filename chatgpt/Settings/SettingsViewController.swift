//
//  SettingViewController.swift
//  chatgpt
//
//  Created by Yuriy on 31.12.2024.
//

import UIKit
import SwiftUI
import Combine

final class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let forescoLogoView = ForescoLogoView()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .bg
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset.bottom = 162
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.register(
            BannerTVCell.self,
            forCellReuseIdentifier: BannerTVCell.identifier
        )
        tableView.register(
            SettingsItemTVCell.self,
            forCellReuseIdentifier: SettingsItemTVCell.identifier
        )
        tableView.register(
            AnotherAppTVCell.self,
            forCellReuseIdentifier: AnotherAppTVCell.identifier
        )
        return tableView
    }()
    
    // MARK: - Initializers
    
    private let preferences: Preferences
    
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
        
        setupTVDelegate()
        
        setupTVConstraints()
        
        setupForescoLogoConstraints()
        
        setupBinding()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = SettingsLocs.title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.setColor(backgroud: .bg, hideLine: true)
    }
    
    // MARK: - Private Methods
    
    private func setupBinding() {
        
        preferences.$isPremiumEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let section = IndexSet(integer: 0)
                tableView.reloadSections(section, with: .fade)
                
            }.store(in: &cancellables)
        
        preferences.$isAuthorized
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let section = IndexSet(integer: 1)
                tableView.reloadSections(section, with: .fade)
            }.store(in: &cancellables)
    }
    
    private func setupTVConstraints() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupForescoLogoConstraints() {
        view.addSubview(forescoLogoView)
        forescoLogoView.bottomConstraints = forescoLogoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        if let bottomConstraints = forescoLogoView.bottomConstraints {
            NSLayoutConstraint.activate([
                forescoLogoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                forescoLogoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                forescoLogoView.heightAnchor.constraint(equalToConstant: 56),
                bottomConstraints
            ])
        }
    }
    
    private func setupTVDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}


// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsSections.allCases[section].numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let section = SettingsSections.allCases[indexPath.section]
        guard let configurator = section.configurator(at: indexPath.row, preferences: preferences) else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: configurator).reuseId, for: indexPath)
        configurator.configure(cell: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionHeaderHeight = SettingsSections.allCases[section].heightForHeaderInSection
        return sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = SettingsSections.allCases[section].viewForHeaderInSection
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionFooterHeight = SettingsSections.allCases[section].heightForFooterInSection
        return sectionFooterHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionFooterView = SettingsSections.allCases[section].viewForFooterInSection
        return sectionFooterView
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionHeight = SettingsSections.allCases[indexPath.section].heightForRowAt
        return sectionHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = SettingsSections.allCases[indexPath.section]
        handleSelection(for: section, at: indexPath.row)
    }
    
    private func handleSelection(for section: SettingsSections, at row: Int) {
        switch section {
        case .banner:
            handleBannerSelection()
            
        case .account:
            handleAccountSelection()
            
        case .language:
            handleLanguageSelection()
            
        case .additional(let items):
            guard items.indices.contains(row) else { return }
            handleAdditionalSelection(items[row])
            
        case .anotherApps(let apps):
            guard apps.indices.contains(row) else { return }
            handleAnotherAppsSelection(apps[row])
        }
    }
    
    private func handleBannerSelection() {
        preferences.isPremiumEnabled.toggle()
    }
    
    private func handleAccountSelection() {
        preferences.isAuthorized.toggle()
    }
    
    private func handleLanguageSelection() {
         Deeplinks.open(type: .appSettings)
    }
    
    private func handleAdditionalSelection(_ item: AdditionalTypesSection) {
        switch item {
        case .restore:
            let alert2 = UIAlertController.create(
                title: "Хуй на",
                message: nil,
                preferredStyle: .alert,
                actions: (title: "ОК", style: .cancel, handler: nil)
            )
            
            let alert3 = UIAlertController.create(
                title: "Пидора ответ",
                message: nil,
                preferredStyle: .alert,
                actions: (title: "ОК", style: .cancel, handler: nil)
            )
            let alert = UIAlertController.create(
                title: "Тигр?",
                message: nil,
                preferredStyle: .alert,
                actions: (title: "Да", style: .default, handler: { [weak self] _ in
                    guard let self else { return }
                    present(alert2, animated: true)
                }),
                (title: "Нет", style: .default, handler: { [weak self] _ in
                    guard let self else { return }
                    present(alert3, animated: true)
                })
            )
            
            present(alert, animated: true)
            
        case .support:
            let controller = SupportBSVC(isPremiumEnambled: preferences.isPremiumEnabled)
            controller.preferredSheetSizing = .fit
            present(controller, animated: true)
            
        case .rateApp:
            print("rateApp")
        case .shareApp:
            let item = "Share item"
            UIActivityViewController.present(viewController: self, activityItems: [item])
        }
    }
    
    private func handleAnotherAppsSelection(_ app: AnotherAppsSection) {
        switch app {
        case .tweety:
            Deeplinks.open(type: .tweety)
        case .luna:
             Deeplinks.open(type: .luna)
        case .dublicator:
             Deeplinks.open(type: .dublicator)
        }
    }
}


extension SettingsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = -scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let compare = self.tableView.frame.height - (yOffset + contentHeight) - 162
       
        if compare <= 62 {
            self.forescoLogoView.bottomConstraints?.constant = -(compare )
        }else{
            self.forescoLogoView.bottomConstraints?.constant = -62
        }
    }
}



final class SupportBSVC: BottomSheetController {
    
    // MARK: - Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Контакты"
        label.font = .SFProText(weight: .semibold, size: 22)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(.closenav, for: .normal)
        button.addTarget(self, action: #selector(dismissHandler), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var horizontalStack: UIStackView = {
        let spacer = UIView()
        spacer.isUserInteractionEnabled = false
        spacer.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        spacer.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, spacer, dismissButton])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(
            SupportCVCell.self,
            forCellWithReuseIdentifier: SupportCVCell.identifier
        )
        return cv
    }()
    
    private let badgeLabel: CopyBadge = {
        let label = CopyBadge()
        label.text = "Адрес скопирован"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let isPremiumEnambled: Bool

    // MARK: - Initializers
    
    init(isPremiumEnambled: Bool) {
        self.isPremiumEnambled = isPremiumEnambled
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
//        view = UIView()
        view.backgroundColor = .alert
        
        setupDelegates()
    
        setupHorizontalStackConstraints()
        
        setupCollectionViewConstraints()
        
        setupBadgeLabelConstraints()
              
    }
    
    // MARK: - Private Methods
    
    private func setupHorizontalStackConstraints() {
        view.addSubview(horizontalStack)
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            horizontalStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            horizontalStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
    }
    
    private func setupCollectionViewConstraints() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: horizontalStack.bottomAnchor, constant: 17),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -64),
            collectionView.heightAnchor.constraint(equalToConstant: 216)
        ])
    }
    
    private func setupBadgeLabelConstraints() {
        view.addSubview(badgeLabel)
        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            badgeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            badgeLabel.widthAnchor.constraint(equalToConstant: 168),
            badgeLabel.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func setupDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc private func dismissHandler() {
        dismiss(animated: true)
    }
}

extension SupportBSVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        CollectionViewTypes.allCases.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
            
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SupportCVCell.identifier,
            for: indexPath
        ) as? SupportCVCell else {
            return UICollectionViewCell()
        }
        
        let config = CollectionViewTypes.allCases[indexPath.item]
        let hideDevider = indexPath.item == CollectionViewTypes.allCases.count - 1
        cell.configure(config, hideDevider: hideDevider, isPremiumEnambled: isPremiumEnambled)
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
            
        let selectedSell = CollectionViewTypes.allCases[indexPath.item]
        let currentDomain = isPremiumEnambled ? selectedSell.domainPremium : selectedSell.domainFree
            
        switch selectedSell {
        case .instagram:
            Deeplinks.openWeb(type: .instagram(currentDomain))
            
        case .telegram:
            Deeplinks.openWeb(type: .telegram(currentDomain))
            
        case .mail:
            UIPasteboard.general.string = currentDomain
            badgeLabel.animate()
        }
    }
}


extension SupportBSVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 72)
    }
}


final class SupportCVCell: UICollectionViewCell {
    
    static let identifier = String(describing: SupportCVCell.self)
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .SFProText(weight: .regular, size: 15)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let image = UIImageView()
        image.image = .arrowrightA
        image.tintColor = .unactive
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let devider: UIView = {
        let devider = UIView()
        devider.backgroundColor = .devider
        devider.translatesAutoresizingMaskIntoConstraints = false
        return devider
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        setupLogoImageViewConstraints()
        
        setupTitleLabelConstaints()
        
        setupArrowImageViewConstaints()
        
        setupDeviderConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setupLogoImageViewConstraints() {
        contentView.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            logoImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            logoImageView.widthAnchor.constraint(equalToConstant: 48),
            logoImageView.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
    
    private func setupTitleLabelConstaints() {
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setupArrowImageViewConstaints() {
        contentView.addSubview(arrowImageView)
        NSLayoutConstraint.activate([
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowImageView.heightAnchor.constraint(equalToConstant: 24),
            arrowImageView.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupDeviderConstraints() {
        contentView.addSubview(devider)
        NSLayoutConstraint.activate([
            devider.heightAnchor.constraint(equalToConstant: 0.5),
            devider.bottomAnchor.constraint(equalTo: bottomAnchor),
            devider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            devider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    
    // MARK: - Public Methods
    
    func configure(_ item: SupportBSVC.CollectionViewTypes, hideDevider: Bool, isPremiumEnambled: Bool) {
        self.logoImageView.image = item.image
        self.devider.isHidden = hideDevider
        if item == .mail {
            let domain = (isPremiumEnambled ? item.domainPremium : item.domainFree)
            self.titleLabel.text = "\(item.title) \(domain)"
        } else {
            self.titleLabel.text = item.title
        }
    }
}


extension SupportBSVC {
    enum CollectionViewTypes: CaseIterable {
        case telegram, instagram, mail
        
        var image: UIImage {
            switch self {
            case .telegram:
                    .telegram
            case .instagram:
                    .instagram
            case .mail:
                    .mail
            }
        }
        
        var title: String {
            switch self {
            case .telegram:
                "Написать нам в Telegram"
            case .instagram:
                "Написать нам в Instagram"
            case .mail:
                "Наша почта:"
            }
        }
        
        var domainFree: String {
            switch self {
            case .telegram:
                "Foresko_Support"
            case .instagram:
                "foresko.apps"
            case .mail:
                "support@foresko.com"
            }
        }
        
        var domainPremium: String {
            switch self {
            case .telegram:
                "Foresko"
            case .instagram:
                "foresko.apps"
            case .mail:
                "support.vip@foresko.com"
            }
        }
    }
}


#if DEBUG
@available(iOS 17.0, *)
#Preview {
    TabBarController()
//    UINavigationController(
//        rootViewController: TabBarController()
//    )
}
#endif




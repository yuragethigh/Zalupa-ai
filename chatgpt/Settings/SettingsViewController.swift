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
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .bg
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset.bottom = 62
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
        setupBinding()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Настройки"
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
    
}

protocol SettingsItemConfiguration {
    var image: UIImage? { get }
    var title: String { get }
}

protocol AnotherAppConfiguration {
    var image: UIImage { get }
    var title: String { get }
    var subtitle: String { get }
}

struct SettingItem: SettingsItemConfiguration {
    let image: UIImage?
    let title: String
}

struct AnotherAppItem: AnotherAppConfiguration {
    let image: UIImage
    let title: String
    let subtitle: String
}

// Дополнительные типы
enum AdditionalTypes: CaseIterable {
    case restore, support, rateApp, shareApp
    
    var image: UIImage? {
        switch self {
        case .restore:
            return .restore
        case .support:
            return .support
        case .rateApp:
            return .rateApp
        case .shareApp:
            return .shareApp
        }
    }
    
    var title: String {
        switch self {
        case .restore:
            return "Восстановить Premium"
        case .support:
            return "Написать в поддержку"
        case .rateApp:
            return "Оценить приложение"
        case .shareApp:
            return "Поделиться приложением"
        }
    }
}

enum AnotherApps: CaseIterable {
    case tweety, luna, dublicator
    
    var image: UIImage {
        switch self {
        case .tweety:
            return .tweety
        case .luna:
            return .luna
        case .dublicator:
            return .dublicator
        }
    }
    
    var title: String {
        switch self {
        case .tweety:
            "Tweety – ИИ Копирайтер"
        case .luna:
            "Luna – Сонник & Гороскоп"
        case .dublicator:
            "Дубликатор – Очистка фото"
        }
    }
    
    var subtitle: String {
        switch self {
        case .tweety:
            "Контент, Посты, Эссе"
        case .luna:
            "Толкование снов и знаки зодиака"
        case .dublicator:
            "Чистка галереи для iPhone"
        }
    }
}

enum SettingsSection {
    case banner
    case account
    case language
    case additional([AdditionalTypes])
    case anotherApps([AnotherApps])
}

extension SettingsSection {
    
    var heightForRowAt: CGFloat {
        switch self {
        case .banner:
            return 124
        case .anotherApps:
            return 100
        default:
            return 64
        }
    }
}

extension SettingsSection {
    var numberOfRows: Int {
        switch self {
        case .banner:
            return 1
        case .account, .language:
            return 1
        case .additional(let items):
            return items.count
        case .anotherApps(let items):
            return items.count
        }
    }
}


extension SettingsSection {
    func item(at index: Int, isAuthorized: Bool, userEmail: String) -> SettingsItemConfiguration? {
        switch self {
            
        case .account:
            let title = isAuthorized ? userEmail : "Аккаунт"
            return SettingItem(image: UIImage(named: "account"), title: title)
            
        case .language:
            return SettingItem(image: UIImage(named: "language"), title: "Язык")
            
        case .additional(let items):
            let additionalType = items[index]
            return SettingItem(image: additionalType.image, title: additionalType.title)
            
        default: return nil
            
        }
    }
}

extension SettingsSection {
    func anotherItem(at index: Int) -> AnotherAppConfiguration? {
        switch self {
        case .anotherApps(let items):
            let anotherAppType = items[index]
            return AnotherAppItem(
                image: anotherAppType.image,
                title: anotherAppType.title,
                subtitle: anotherAppType.subtitle
            )
            
        default: return nil

        }
    }
}

extension SettingsSection: CaseIterable {
    static var allCases: [SettingsSection] {
        return [
            .banner,
            .account,
            .language,
            .additional(AdditionalTypes.allCases),
            .anotherApps(AnotherApps.allCases)
        ]
    }
}




// MARK: - UITableViewDataSource / UITableViewDelegate

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        let settingsSection = SettingsSection.allCases[section]
        return settingsSection.numberOfRows
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let settingsSection = SettingsSection.allCases[indexPath.section]
        
        switch settingsSection {
            
        case .banner:
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: BannerTVCell.identifier
            ) as? BannerTVCell else {
                return UITableViewCell()
            }
            
            let view = PremiumBannerView(isPremium: preferences.isPremiumEnabled)
            let anyView = AnyView(view)
            
            cell.configure(anyView)
            return cell
            
        case .account, .language, .additional:
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsItemTVCell.identifier
            ) as? SettingsItemTVCell else {
                return UITableViewCell()
            }
            
            if let item = settingsSection.item(
                at: indexPath.row,
                isAuthorized: preferences.isAuthorized,
                userEmail: "za@yy.rr"
            ) {
                cell.configure(item)
            }
            
            if case .additional = settingsSection {
                let isFirst = indexPath.row == 0
                let isLast = indexPath.row == settingsSection.numberOfRows - 1
                cell.updateCorners(isFirst: isFirst, isLast: isLast)
                cell.updateDevider(isLast: isLast)
            }
            
            return cell
            
        case .anotherApps:
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: AnotherAppTVCell.identifier
            ) as? AnotherAppTVCell else {
                return UITableViewCell()
            }
            
            if let item = settingsSection.anotherItem(at: indexPath.row) {
                cell.configure(item)

            }
            
            return cell
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        let settingsSection = SettingsSection.allCases[indexPath.section]
        return settingsSection.heightForRowAt
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        let settingsSection = SettingsSection.allCases[indexPath.section]
        
        switch settingsSection {
        case .banner:
            print("banner")
            preferences.isPremiumEnabled.toggle()
        case .account:
            preferences.isAuthorized.toggle()
            print("account")
        case .language:
            print("language")
        case .additional(let items):
            let selectedItem = items[indexPath.row]
            switch selectedItem {
            case .restore:
                print("restore")
            case .support:
                print("support")
            case .rateApp:
                print("rateApp")
            case .shareApp:
                print("shareApp")
            }
        case .anotherApps(let items):
            let selectedItem = items[indexPath.row]
            
            switch selectedItem {
            case .tweety:
                print("tweety")
            case .luna:
                print("luna")
            case .dublicator:
                print("dublicator")
            }
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        let settingsSection = SettingsSection.allCases[section]
 
        switch settingsSection {
        case .anotherApps:
            return 32
        default:
            return 0
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let settingsSection = SettingsSection.allCases[section]

        switch settingsSection {
        case .anotherApps:
            
            return AnotherAppTVHeader()
            
        default:
            return nil
        }

    }
    
    
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        let settingsSection = SettingsSection.allCases[section]

        switch settingsSection {
        case .anotherApps:
            return 0
            
        default:
            return 24
        }
        
    }
    
    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        let settingsSection = SettingsSection.allCases[section]

        switch settingsSection {
        case .anotherApps:
            return nil
            
        default:
            let footerView = UIView()
            footerView.backgroundColor = .clear
            return footerView
        }

    }
}








//MARK: - Setups table view

private extension SettingsViewController {
    private func setupTVConstraints() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupTVDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}



#if DEBUG
@available(iOS 17.0, *)
#Preview {
    UINavigationController(
        rootViewController: SettingsViewController(preferences: .shared)
    )
}
#endif




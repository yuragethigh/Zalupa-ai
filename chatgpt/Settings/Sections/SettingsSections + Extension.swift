//
//  SettingsSections + Extension.swift
//  chatgpt
//
//  Created by Yuriy on 15.01.2025.
//

import UIKit

extension SettingsSections {
    func configurator(at index: Int, preferences: Preferences) -> CellConfigurator? {
        switch self {
        case .banner:
            return BannerCellConfigurator(isPremium: preferences.isPremiumEnabled)
            
        case .account:
            let title = preferences.isAuthorized ? Preferences.shared.userEmail : SettingsLocs.account
            let item = SettingsItem(image: .account, title: title)
            return SettingsItemCellConfigurator(item: item, section: self, row: index)
            
        case .language:
            let item = SettingsItem(image: .language, title: SettingsLocs.language)
            return SettingsItemCellConfigurator(item: item, section: self, row: index)
            
        case .additional(let items):
            let additionalType = items[index]
            let item = SettingsItem(image: additionalType.image, title: additionalType.title)
            return SettingsItemCellConfigurator(item: item, section: self, row: index)
            
        case .anotherApps(let apps):
            let appType = apps[index]
            let app = AnotherAppItem(image: appType.image, title: appType.title, subtitle: appType.subtitle)
            return AnotherAppCellConfigurator(app: app)
        }
    }
}

extension SettingsSections {
    
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
    
    var heightForHeaderInSection: CGFloat {
        switch self {
        case .anotherApps:
            return 32
        case .banner:
            return 16
        default:
            return 0
        }
    }
    
    var viewForHeaderInSection: UIView? {
        switch self {
        case .anotherApps:
            return AnotherAppTVHeader()
        case .banner:
            let footerView = UIView()
            footerView.backgroundColor = .clear
            return footerView
        default:
            return nil
        }
    }
    
    var heightForFooterInSection: CGFloat {
        switch self {
        case .anotherApps:
            return 0
        default:
            return 24
        }
    }
    
    var viewForFooterInSection: UIView? {
        switch self {
        case .anotherApps:
            return nil
        default:
            let footerView = UIView()
            footerView.backgroundColor = .clear
            return footerView
        }
    }
}


extension SettingsSections {
    static var allCases: [SettingsSections] {
        return [
            .banner,
            .account,
            .language,
            .additional(AdditionalTypesSection.allCases),
            .anotherApps(AnotherAppsSection.allCases)
        ]
    }
}


//
//  AdditionalTypes.swift
//  chatgpt
//
//  Created by Yuriy on 15.01.2025.
//

import UIKit

enum AdditionalTypesSection: CaseIterable {
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
            return SettingsLocs.restore
        case .support:
            return SettingsLocs.support
        case .rateApp:
            return SettingsLocs.rateApp
        case .shareApp:
            return SettingsLocs.shareApp
        }
    }
}

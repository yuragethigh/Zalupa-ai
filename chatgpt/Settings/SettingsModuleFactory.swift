//
//  SettingsModuleFactory.swift
//  chatgpt
//
//  Created by Yuriy on 31.12.2024.
//

import UIKit

struct SettingsModuleFactory {
    
    static func createModule() -> UIViewController {
        let preferences = Preferences.shared
        
        let viewController = SettingsViewController(preferences: preferences)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        return navigationController
    }
    
}


//
//  Preferences.swift
//  chatgpt
//
//  Created by Yuriy on 28.12.2024.
//

import Foundation

final class Preferences {
    
    static let shared = Preferences()
    
    @UserDefault(Preferences.Key.isListModeEnabled) var isListModeEnabled = false
    @UserDefault(Preferences.Key.isPremiumEnabled) var isPremiumEnabled = false
    @UserDefault(Preferences.Key.isAuthorized) var isAuthorized = false
    @UserDefault(Preferences.Key.micPerission) var micPerission = false
    @UserDefault(Preferences.Key.userEmail) var userEmail = "zalup0k@gmail.com"
}

private extension Preferences {
    private enum Key {
        static let isListModeEnabled = "isListModeEnabled"
        static let isPremiumEnabled = "isPremiumEnabled"
        static let isAuthorized = "isAuthorized"
        static let micPerission = "micPerission"
        static let userEmail = "userEmail"
    }
}

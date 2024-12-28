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
}

extension Preferences {
    enum Key {
        static let isListModeEnabled = "isListModeEnabled"
    }
}

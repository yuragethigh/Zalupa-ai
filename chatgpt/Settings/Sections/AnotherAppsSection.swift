//
//  AnotherAppsSection.swift
//  chatgpt
//
//  Created by Yuriy on 15.01.2025.
//

import UIKit

enum AnotherAppsSection: CaseIterable {
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
            SettingsLocs.tweetyTitle
        case .luna:
            SettingsLocs.lunaTitle
        case .dublicator:
            SettingsLocs.dublicatorTitle
        }
    }
    
    var subtitle: String {
        switch self {
        case .tweety:
            SettingsLocs.tweetySubtitle
        case .luna:
            SettingsLocs.lunaSubtitle
        case .dublicator:
            SettingsLocs.dublicatorSubtitle
        }
    }
}

//
//  Deeplinks.swift
//  chatgpt
//
//  Created by Yuriy on 15.01.2025.
//

import UIKit

struct Deeplinks {
    static func open(type: LinkName) {
        guard let url = URL(string: type.urlString) else { return }
        UIApplication.shared.open(url, options: [:])
    }
    
    static func openWeb(type: LinkName) {
        guard let url = URL(string: type.urlString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
            
        } else {
            let webUrlString = type.webUrlString
            if let webUrl = URL(string: webUrlString) {
                UIApplication.shared.open(webUrl, options: [:])
            }
            
        }
    }
}

extension Deeplinks {
    enum LinkName {
        case appSettings, tweety, luna, dublicator, telegram(String), instagram(String), foreskoSite
        
        var urlString: String {
            switch self {
            case .appSettings:
                return UIApplication.openSettingsURLString
            case .tweety:
                return "https://apps.apple.com/ru/app/id6450050261"
            case .luna:
                return "https://apps.apple.com/ru/app/id6450316156"
            case .dublicator:
                return "https://apps.apple.com/ru/app/id1536440020"
            case .telegram(let value):
                return "tg://resolve?domain=\(value)"
            case .instagram(let value):
                return "instagram://user?username=\(value)"
            case .foreskoSite:
                return "https://foresko.com/ru/"
            }
        }
        
        var webUrlString: String {
            switch self {
            case .telegram(let value):
                return "https://t.me/\(value)"
            case .instagram(let value):
                return "https://www.instagram.com/\(value)"
           
            default:
                return ""
            }
        }
    }
}



//
//  DaySection.swift
//  chatgpt
//
//  Created by Yuriy on 24.01.2025.
//

import UIKit

struct DaySection {
    let date: Date
    var messages: [MessageModel]
}

struct MessageModel: MessageConfiguration {
    var text: String?
    let image: UIImage?
    let messageType: MessageType
    let creationDate: Date = Date()
    
    var sendingTime: String {
        return creationDate.localizedTimeString()
    }
}

enum MessageType {
    case user, ai
}

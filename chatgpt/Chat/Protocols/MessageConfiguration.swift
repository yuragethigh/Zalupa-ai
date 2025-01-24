//
//  MessageConfiguration.swift
//  chatgpt
//
//  Created by Yuriy on 24.01.2025.
//

import UIKit

protocol MessageConfiguration {
    var text: String? { get }
    var image: UIImage? { get }
    var messageType: MessageType { get }
    var sendingTime: String { get }
}

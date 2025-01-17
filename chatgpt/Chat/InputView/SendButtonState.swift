//
//  SendButtonState.swift
//  chatgpt
//
//  Created by Yuriy on 13.01.2025.
//

import UIKit

enum SendButtonState {
    case requestMicPermission      // нет текста + micPermission = false
    case openBottomSheet           // нет текста + micPermission = true
    case send                      // есть текст (micPermission неважен)
    
    var currentImage: UIImage {
        switch self {
        case .requestMicPermission: .voiceNotAvailable
        case .openBottomSheet: .voice
        case .send: .send
        }
    }
}

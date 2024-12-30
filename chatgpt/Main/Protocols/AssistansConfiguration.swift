//
//  AssistansConfiguration.swift
//  chatgpt
//
//  Created by Yuriy on 26.12.2024.
//

import Foundation

protocol AssistansConfiguration {
    var title: String { get }
    var name: String { get }
    var description: String { get }
    var imageDefault: URL? { get }
    var imageLocked: URL? { get }
    var imageAvatar: URL? { get }
    var isPremium: Bool { get }
    var systemMessage: String { get }
    var clues: [Clues] { get }
}

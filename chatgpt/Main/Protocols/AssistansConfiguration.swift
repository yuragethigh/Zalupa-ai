//
//  AssistansConfiguration.swift
//  chatgpt
//
//  Created by Yuriy on 26.12.2024.
//

import Foundation

protocol AssistantsConfiguration {
    var title: String { get }
    var name: String { get }
    var description: String { get }
    var imageAvatar: URL? { get }
    var animation: URL? { get }
    var backgroundColor: AssistantsColors { get }
    var freeAssistant: Bool { get }
    var systemMessage: String { get }
    var clues: [Clues] { get }
}

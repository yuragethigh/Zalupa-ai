//
//  CollectionCellModel.swift
//  chatgpt
//
//  Created by Yuriy on 26.12.2024.
//

import Foundation

struct CollectionCellModel: AssistansConfiguration, Decodable {
    
    let title: String
    let name: String
    let description: String
    let imageDefault: URL?
    let imageLocked: URL?
    let imageAvatar: URL?
    let isPremium: Bool
    let systemMessage: String
    let clues: [Clues]
    
    init(
        title: String,
        name: String,
        description: String,
        imageDefault: String,
        imageLocked: String,
        imageAvatar: String,
        isPremium: Bool,
        systemMessage: String,
        clues: [Clues]
    ) {
        self.title = title
        self.name = name
        self.description = description
        self.imageDefault = imageDefault.asURL
        self.imageLocked = imageLocked.asURL
        self.imageAvatar = imageAvatar.asURL
        self.isPremium = isPremium
        self.systemMessage = systemMessage
        self.clues = clues
    }
}

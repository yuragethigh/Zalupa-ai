//
//  CollectionCellModel.swift
//  chatgpt
//
//  Created by Yuriy on 26.12.2024.
//

import Foundation

struct AssistansModel: AssistantsConfiguration, Decodable {
    let id: String
    let title: String
    let name: String
    let description: String
    @EmptyAsNilURL var imageAvatar: URL?
    @EmptyAsNilURL var animation: URL?
    let backgroundColor: AssistantsColors
    let freeAssistant: Bool
    let systemMessage: String
    let clues: [Clues]
}

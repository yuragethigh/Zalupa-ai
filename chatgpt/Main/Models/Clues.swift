//
//  Clues.swift
//  chatgpt
//
//  Created by Yuriy on 26.12.2024.
//

import Foundation

struct Clues: Decodable {
    let clueTitle: String
    let clueDescription: String
    @EmptyAsNilURL var img: URL?

}

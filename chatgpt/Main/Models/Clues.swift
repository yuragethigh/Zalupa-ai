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
    let img: URL?
    
    init(clueTitle: String, clueDescription: String, img: String) {
        self.clueTitle = clueTitle
        self.clueDescription = clueDescription
        self.img = img.asURL
    }
}

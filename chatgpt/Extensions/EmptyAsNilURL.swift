//
//  String + Extension.swift
//  chatgpt
//
//  Created by Yuriy on 26.12.2024.
//

import Foundation

@propertyWrapper
struct EmptyAsNilURL: Decodable {
    var wrappedValue: URL?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        wrappedValue = string.isEmpty ? nil : URL(string: string)
    }
}

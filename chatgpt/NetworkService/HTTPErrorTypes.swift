//
//  HTTPErrorTypes.swift
//  chatgpt
//
//  Created by Yuriy on 26.12.2024.
//

import Foundation

enum HTTPErrorTypes: Error {
    case invalidURL
    case decodingError(Error)
    case failableCastResponse
    case invalidStatusCode(Int, String)
}


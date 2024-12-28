//
//  String + Extension.swift
//  chatgpt
//
//  Created by Yuriy on 26.12.2024.
//

import Foundation

extension String {
    var asURL: URL? {
        return URL(string: self)
    }
}

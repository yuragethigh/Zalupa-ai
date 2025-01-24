//
//  Date + Extension.swift
//  chatgpt
//
//  Created by Yuriy on 22.01.2025.
//

import Foundation

extension Date {
    func localizedTimeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}


//
//  SelectItemDelegate.swift
//  chatgpt
//
//  Created by Yuriy on 26.12.2024.
//

import Foundation

protocol SelectItemDelegate: AnyObject {
    func collectionTableViewCell(didSelectItem model: AssistantsConfiguration)
}

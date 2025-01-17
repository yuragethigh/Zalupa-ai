//
//  CellConfigurator.swift
//  chatgpt
//
//  Created by Yuriy on 15.01.2025.
//

import UIKit

protocol CellConfigurator {
    static var reuseId: String { get }
    func configure(cell: UITableViewCell)
}

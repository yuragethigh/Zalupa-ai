//
//  AnotherAppCellConfigurator.swift
//  chatgpt
//
//  Created by Yuriy on 15.01.2025.
//

import UIKit

struct AnotherAppCellConfigurator: CellConfigurator {
    static let reuseId = AnotherAppTVCell.identifier
    
    let app: AnotherAppConfiguration
    
    func configure(cell: UITableViewCell) {
        guard let cell = cell as? AnotherAppTVCell else { return }
        cell.configure(app)
    }
}

//
//  SettingsItemCellConfigurator.swift
//  chatgpt
//
//  Created by Yuriy on 15.01.2025.
//

import UIKit

struct SettingsItemCellConfigurator: CellConfigurator {
    static let reuseId = SettingsItemTVCell.identifier
    
    let item: SettingsItemConfiguration
    let section: SettingsSections
    let row: Int
    
    func configure(cell: UITableViewCell) {
        guard let cell = cell as? SettingsItemTVCell else { return }
        cell.configure(item)
        if case .additional = section {
            let isFirst = row == 0
            let isLast = row == section.numberOfRows - 1
            cell.updateCorners(isFirst: isFirst, isLast: isLast)
            cell.updateDevider(isLast: isLast)
        }
    }
}

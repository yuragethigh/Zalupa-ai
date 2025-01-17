//
//  BannerCellConfigurator.swift
//  chatgpt
//
//  Created by Yuriy on 15.01.2025.
//

import SwiftUI

struct BannerCellConfigurator: CellConfigurator {
    static let reuseId = BannerTVCell.identifier
    
    let isPremium: Bool
    
    func configure(cell: UITableViewCell) {
        guard let cell = cell as? BannerTVCell else { return }
        let view = PremiumBannerView(isPremium: isPremium)
        cell.configure(AnyView(view))
    }
}


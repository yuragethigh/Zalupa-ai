//
//  UITableView + Extension.swift
//  chatgpt
//
//  Created by Yuriy on 27.12.2024.
//

import UIKit

extension UITableView {
    func updateSections(_ section: Int) {
        self.reloadSections(.init(integer: section), with: .fade)
    }
}

//
//  TableDisplayStrategy.swift
//  chatgpt
//
//  Created by Yuriy on 29.12.2024.
//

import UIKit

protocol TableDisplayStrategy {
    func numberOfSections() -> Int
    func numberOfRows(in section: Int) -> Int
    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell
    func heightForRow(at indexPath: IndexPath) -> CGFloat
    func heightForHeader(in section: Int) -> CGFloat
    func viewForHeader(in section: Int) -> UIView?
    func didSelectRow(at indexPath: IndexPath)
    func canEditRow(at indexPath: IndexPath) -> Bool
    func trailingSwipeActionsConfiguration(
        forRowAt indexPath: IndexPath,
        in tableView: UITableView,
        deleteActionHandler: @escaping (IndexPath, @escaping (Bool) -> Void) -> Void
    ) -> UISwipeActionsConfiguration?
}


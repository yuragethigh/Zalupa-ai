//
//  ListModeStrategy.swift
//  chatgpt
//
//  Created by Yuriy on 31.12.2024.
//

import UIKit

final class ListModeStrategy: TableDisplayStrategy {
    
    
    private var assistans: [AssistantsConfiguration]
    private var isPremium: Bool
    
    weak var selectItemDelegate: SelectItemDelegate?
    
    
    init(
        assistans: [AssistantsConfiguration],
        isPremium: Bool,
        selectItemDelegate: SelectItemDelegate
    ) {
        self.assistans = assistans
        self.isPremium = isPremium
        self.selectItemDelegate = selectItemDelegate
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(in section: Int) -> Int {
        return assistans.count
    }

    func cellForRow(
        at indexPath: IndexPath,
        in tableView: UITableView
    ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ListModeTVCell.identifier
        ) as? ListModeTVCell else {
            return UITableViewCell()
        }
        
        let item = assistans[indexPath.item]
                
        cell.configure(item, isPremium: isPremium)
        
        return cell
    }
    
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        return 76
    }

    func heightForHeader(in section: Int) -> CGFloat {
        return 0
    }

    func viewForHeader(in section: Int) -> UIView? {
        return nil
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let selectedModel = assistans[indexPath.row]
        selectItemDelegate?.collectionTableViewCell(didSelectItem: selectedModel)
    }
    
    func canEditRow(at indexPath: IndexPath) -> Bool {
        return false
    }
    
    func trailingSwipeActionsConfiguration(
        forRowAt indexPath: IndexPath,
        in tableView: UITableView,
        deleteActionHandler: @escaping (IndexPath, @escaping (Bool) -> Void) -> Void
    ) -> UISwipeActionsConfiguration? {

        return nil
    }
}


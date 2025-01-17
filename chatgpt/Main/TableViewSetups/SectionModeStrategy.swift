//
//  SectionModeStrategy.swift
//  chatgpt
//
//  Created by Yuriy on 31.12.2024.
//

import UIKit

final class SectionModeStrategy: TableDisplayStrategy {
    
    private let assistans: [AssistantsConfiguration]
    private let historyChats: [HistoryChatConfiguration]
    private let isPremium: Bool
    
    weak var selectItemDelegate : SelectItemDelegate?
    
    init(
        assistans: [AssistantsConfiguration],
        historyChats: [HistoryChatConfiguration],
        isPremium: Bool,
        selectItemDelegate : SelectItemDelegate
    ) {
        self.assistans = assistans
        self.historyChats = historyChats
        self.isPremium = isPremium
        self.selectItemDelegate = selectItemDelegate
    }

    func numberOfSections() -> Int {
        return MainTVSection.allCases.count
    }

    func numberOfRows(in section: Int) -> Int {
        
        switch MainTVSection.allCases[section] {
        case .assistans :
            return 1
            
        case .chatHistory:
            return historyChats.isEmpty ? 1 : historyChats.count

        }

    }

    func cellForRow(
        at indexPath: IndexPath,
        in tableView: UITableView) -> UITableViewCell {
        
        switch MainTVSection.allCases[indexPath.section] {
            
        case .assistans :
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: HorizontalTVCell.identifier
            ) as? HorizontalTVCell else {
                return UITableViewCell()
            }
            
            cell.configure(
                with: assistans,
                isPremium: isPremium
            )
            cell.delegate = selectItemDelegate
            return cell
            
        case .chatHistory:
            
            if historyChats.isEmpty {
                
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ChatHistoryPlaceholderTVCell.identifier
                ) as? ChatHistoryPlaceholderTVCell else {
                    return UITableViewCell()
                }
                return cell
                
            } else {
                
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ChatHistoryTVCell.identifier
                ) as? ChatHistoryTVCell else {
                    return UITableViewCell()
                }
                
                let items = historyChats[indexPath.row]
                cell.configure(items)
                return cell
            }
        }
    }

    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        
        switch MainTVSection.allCases[indexPath.section] {
            
        case .assistans :
            return 407 + 32 + 10
            
        case .chatHistory:
            return historyChats.isEmpty ? 232 : 76
        }
        
    }

    func heightForHeader(in section: Int) -> CGFloat {
        
        switch MainTVSection.allCases[section] {
        case .assistans:
            return 0
        case .chatHistory:
            return 64
        }
    }

    func viewForHeader(in section: Int) -> UIView? {
        
        switch MainTVSection.allCases[section] {
        case .assistans:
            return nil
        case .chatHistory:
            return ChatListSectionHeader()
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {

    }
    
    func canEditRow(at indexPath: IndexPath) -> Bool {
        
        switch MainTVSection.allCases[indexPath.section] {
        case .assistans:
            return false
        case .chatHistory:
            return true
        }
    }
    
    
    func trailingSwipeActionsConfiguration(
        forRowAt indexPath: IndexPath,
        in tableView: UITableView,
        deleteActionHandler: @escaping (IndexPath, @escaping (Bool) -> Void) -> Void
    ) -> UISwipeActionsConfiguration? {
        
        switch MainTVSection.allCases[indexPath.section] {
            
        case .assistans:
            return nil
            
        case .chatHistory:
            guard !historyChats.isEmpty else { return nil }
            
            let deleteAction = UIContextualAction(
                style: .destructive,
                title: nil
            ) { (_, _, completionHandler) in
            
                deleteActionHandler(indexPath) { confirmed in
                    completionHandler(confirmed)
                }
            }
            
            deleteAction.image = .delete
            deleteAction.backgroundColor = .systemRed
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = true
            
            return configuration
        }
    }
}


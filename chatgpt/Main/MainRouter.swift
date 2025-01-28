//
//  MainRouter.swift
//  chatgpt
//
//  Created by Yuriy on 28.12.2024.
//

import UIKit

final class MainRouter {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func presentChatView(selectedAssistans: AssistantsConfiguration) {
        let preferences = Preferences.shared
        let permissionVoiceInput = PermissionVoiceInput()
        let presenter = ChatPresenter(
            selectedAssistans: selectedAssistans,
            chatQuery: ChatQuery(id: selectedAssistans.id, daySection: [])
        )
        
        let chatViewController = ChatViewController(
            presenter: presenter,
            preferences: preferences,
            permissionVoiceInput: permissionVoiceInput
        )
        
        let navigationController = UINavigationController(rootViewController: chatViewController)
        navigationController.modalPresentationStyle = .overFullScreen
        viewController?.present(navigationController, animated: true)
    }
    
}


//
//  TabbarRouter.swift
//  chatgpt
//
//  Created by Yuriy on 24.12.2024.
//

import UIKit

final class TabbarRouter {
   
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func presentViewController(defaultAssistants: AssistantsConfiguration) {
        let preferences = Preferences.shared
        let permissionVoiceInput = PermissionVoiceInput()
        let presenter = ChatPresenter(
            selectedAssistans: defaultAssistants,
            chatQuery: mockData()
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



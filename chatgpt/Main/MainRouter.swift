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
    
    func presentChatView() {
        let preferences = Preferences.shared
        
        let chatViewController = ChatViewController(preferences: preferences)
        let navigationController = UINavigationController(rootViewController: chatViewController)
        navigationController.modalPresentationStyle = .overFullScreen
        viewController?.present(navigationController, animated: true)
    }
    
}


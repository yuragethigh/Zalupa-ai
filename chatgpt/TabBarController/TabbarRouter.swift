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
    
    func presentViewController() {
        let chatViewController = ChatViewController()
        let navigationController = UINavigationController(rootViewController: chatViewController)
        navigationController.modalPresentationStyle = .overFullScreen
        viewController?.present(navigationController, animated: true)
    }
}



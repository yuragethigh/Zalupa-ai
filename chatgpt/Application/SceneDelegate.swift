//
//  SceneDelegate.swift
//  chatgpt
//
//  Created by Yuriy on 24.12.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let controller = TabBarController()
//        let controller = UINavigationController(rootViewController: TestVC())

        window?.rootViewController = controller
        window?.makeKeyAndVisible()
    }

}



//
//  MainModuleFactory.swift
//  chatgpt
//
//  Created by Yuriy on 27.12.2024.
//

import UIKit

struct MainModuleFactory {
    static func createModule() -> UIViewController {
        
        let networkService = Network()
        let viewModel = MainViewModel(networkService: networkService)
        let preferences = Preferences.shared
        
        
        let mainViewController = MainViewController(viewModel: viewModel, preferences: preferences)
        let mainRouter = MainRouter(viewController: mainViewController)
        mainViewController.configure(router: mainRouter)
        
        return UINavigationController(rootViewController: mainViewController)
    }
}


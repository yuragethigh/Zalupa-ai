//
//  TabbarDelegate + Extension.swift
//  chatgpt
//
//  Created by Yuriy on 24.12.2024.
//

import UIKit

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return true
        }
        if selectedIndex == 1 {
            return false
        }
        
        return true
    }
    
}

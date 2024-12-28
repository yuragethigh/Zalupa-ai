//
//  Tabbar + Extension.swift
//  chatgpt
//
//  Created by Yuriy on 24.12.2024.
//

import UIKit

extension TabBarController {
    
    func tabbarItemConfigure(
        vc: UIViewController,
        title: String,
        image: UIImage,
        tag: Int
    ) {
        let tabBarItem = UITabBarItem(
            title: title,
            image: image,
            tag: tag
        )
        vc.tabBarItem = tabBarItem
    }
    
}


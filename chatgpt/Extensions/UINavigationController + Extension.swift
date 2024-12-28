//
//  UINavigationController.swift
//  GPTClone
//
//  Created by Yuriy on 30.09.2024.
//

import UIKit

extension UINavigationController {
    
    func setColor(backgroud: UIColor, hideLine: Bool) {
        if #available(iOS 13.0, *) {
            let appearance = self.navigationBar.standardAppearance
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = backgroud
            if hideLine {
                appearance.shadowColor = .clear
            }
            self.navigationBar.standardAppearance = appearance
//            self.navigationBar.scrollEdgeAppearance = appearance
            
        }else{
            if backgroud != .clear {
                self.navigationBar.barTintColor = backgroud
                self.navigationBar.setValue(hideLine, forKey: "hidesShadow")
            }else{
                self.navigationBar.setBackgroundImage(UIImage(), for: .default)
                self.navigationBar.shadowImage = UIImage()
            }
        }
    }
    
    
    func setLargeTitle(color: UIColor, font: UIFont) {
        if #available(iOS 13.0, *) {
            let appearance = self.navigationBar.standardAppearance
            appearance.largeTitleTextAttributes = [.foregroundColor: color, .font: font]
            
            self.navigationBar.standardAppearance = appearance
//            self.navigationBar.scrollEdgeAppearance = appearance
            
        }else{
            self.navigationBar.largeTitleTextAttributes = [.foregroundColor: color, .font: font]
        }
    }
    
}

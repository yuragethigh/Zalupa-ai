//
//  UIFont + Extension.swift
//  GPTClone
//
//  Created by Yuriy on 30.09.2024.
//

import UIKit

extension UIFont {
    class func SFProText(weight: Weight, size: CGFloat) -> UIFont {
        var name = "SFProText-"
        switch weight {
        case .light: name += "Light"
        case .medium: name += "Medium"
        case .regular: name += "Regular"
        case .semibold: name += "Semibold"
        case .bold: name += "Bold"
        case .thin: name += "Thin"
        case .black: name += "Black"
        case .heavy: name += "Heavy"
        case .ultraLight: name += "UltraLight"
        default:
            fatalError("unknown font")
        }
        
        return UIFont(name: name, size: size)!
    }
    
    class func SFProRounded(weight: Weight, size: CGFloat) -> UIFont {
        var name = "SFProRounded-"
        switch weight {
        case .light: name += "Light"
        case .medium: name += "Medium"
        case .regular: name += "Regular"
        case .semibold: name += "Semibold"
        case .bold: name += "Bold"
        case .thin: name += "Thin"
        case .black: name += "Black"
        case .heavy: name += "Heavy"
        case .ultraLight: name += "UltraLight"
        default:
            fatalError("unknown font")
        }
        
        return UIFont(name: name, size: size)!
    }
    
    class func SFProDisplay(weight: Weight, size: CGFloat) -> UIFont {
        var name = "SFProDisplay-"
        switch weight {
        case .light: name += "Light"
        case .medium: name += "Medium"
        case .regular: name += "Regular"
        case .semibold: name += "Semibold"
        case .bold: name += "Bold"
        case .thin: name += "Thin"
        case .black: name += "Black"
        case .heavy: name += "Heavy"
        case .ultraLight: name += "UltraLight"
        default:
            fatalError("unknown font")
        }
        
        return UIFont(name: name, size: size)!
    }
}

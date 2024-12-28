//
//  Font + Extension.swift
//  GPTClone
//
//  Created by Yuriy on 09.10.2024.
//

import SwiftUI

enum SFProText: String {
    
    case bold = "SFProText-Bold"
    case light = "SFProText-Light"
    case medium = "SFProText-Medium"
    case regular = "SFProText-Regular"
    case semibold = "SFProText-Semibold"
    
}

private struct SFProTextFont: ViewModifier {
    
    var type: SFProText
    var size: CGFloat
    var color: Color
    
    init(_ type: SFProText, size: CGFloat = 16, color: Color) {
        self.type = type
        self.size = size
        self.color = color
    }
    
    func body(content: Content) -> some View {
        content
            .font(.custom(type.rawValue, size: size))
            .foregroundColor(color)
        
    }
}

extension View {
    func sfPro(_ type: SFProText, size: CGFloat, color: Color) -> some View {
        modifier(SFProTextFont(type, size: size, color: color))
    }
}

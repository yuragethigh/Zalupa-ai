//
//  CustomTabButton + SUIextension.swift
//  chatgpt
//
//  Created by Yuriy on 24.12.2024.
//

import SwiftUI

struct CustomTabButtonSUI: View {
    var body: some View {
        
        ZStack {
            
            Circle()
                .fill(firstGt)
            
            Circle()
                .fill(secondGt)
                .padding(5)
            
            Image(.customTab)
        }
        .frame(width: 84, height: 84)
    }
    
    private var firstGt: LinearGradient {
        LinearGradient(
            colors: [.paywallLeading, .paywallTrailing ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var secondGt: LinearGradient {
        LinearGradient(
            colors: [.bannerLeading, .bannerTrailing ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}



//
//  PremiumBannerView.swift
//  chatgpt
//
//  Created by Yuriy on 02.01.2025.
//

import SwiftUI

struct PremiumBannerView: View {
    
    private let isPremium: Bool
    
    init(isPremium: Bool) {
        self.isPremium = isPremium
    }
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            Image(image)
            
            VStack(alignment: .leading, spacing: 9) {
                
                HStack(spacing: 4) {
                    
                    Text(title)
                        .sfPro(.semibold, size: 17, color: .white)
                    
                    Image(.arrowrightA)
                        .renderingMode(.template)
                        .foregroundColor(.white)
                }
                
                Text(subtitle)
                    .sfPro(.regular, size: 13, color: .white)

            }
            .padding(.trailing, 32)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(gradient)
    }
    
    private var image: ImageResource {
        isPremium ? .imgPremium : .imgNotPremium
    }
    
    private var title: String {
        isPremium ? "Premium-версия" : "Попробуйте бесплатно"
    }
    
    private var subtitle: String {
        isPremium ? "Наслаждайтесь всеми преимуществами без ограничений" : "Кликните сюда, чтобы получить доступ к премиум-версии"
    }
    
    private var gradient: LinearGradient {
        isPremium ?
        LinearGradient(
            colors: [.paywall2Leading, .paywall2Trailing],
            startPoint: .leading,
            endPoint: .trailing
        )
        :
        LinearGradient(
            colors: [.paywallLeading, .paywallTrailing],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}


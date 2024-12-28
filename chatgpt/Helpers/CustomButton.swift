//
//  CustomButton.swift
//  chatgpt
//
//  Created by Yuriy on 24.12.2024.
//

import UIKit
import SwiftUI

final class CustomButton<ContentView: View>: UIButton {
    
    private let host: UIHostingController<ContentView>
    private let contentView: ContentView
    
    init(_ contentView: ContentView) {
        self.contentView = contentView
        self.host = UIHostingController(rootView: contentView)
        super.init(frame: .zero)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        backgroundColor = .clear
        
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear
        
        addSubview(host.view)
        
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            host.view.topAnchor.constraint(equalTo: topAnchor),
            host.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let isInside = self.point(inside: point, with: event)
        if isInside {
            return self
        }
        return super.hitTest(point, with: event)
    }
    
}


#if DEBUG
@available(iOS 17.0, *)
#Preview {
//    SUI()
    CustomButton(CustomTabButtonSUI())
}
#endif


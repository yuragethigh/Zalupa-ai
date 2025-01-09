//
//  UIViewController + Extension.swift
//  chatgpt
//
//  Created by Yuriy on 31.12.2024.
//

import UIKit

extension UIViewController {
    func alertController(
        title: String?,
        message: String?,
        preferredStyle: UIAlertController.Style,
        completionHandler: @escaping ((Bool) -> Void)
    ) -> UIAlertController {
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: preferredStyle
        )
        
        let deleteAction = UIAlertAction(
            title: "Удалить",
            style: .destructive
        ) {  _ in
            completionHandler(true)
        }
        
        let cancelAction = UIAlertAction(
            title: "Отмена",
            style: .cancel
        ) { _ in
            completionHandler(false)
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        return alert
        
    }
}



extension UIViewController {
    func safeAreaBottomView(window: UIWindow?, filledColor: UIColor) {
        guard let window = view.window else { return }
        
        let fillerView = UIView()
        fillerView.backgroundColor = filledColor
        fillerView.translatesAutoresizingMaskIntoConstraints = false
        
        window.addSubview(fillerView)

        NSLayoutConstraint.activate([
            fillerView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            fillerView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            fillerView.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor),
            fillerView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])
    }
}



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


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

import UIKit

extension UIAlertController {
    static func create(
        title: String? = nil,
        message: String? = nil,
        preferredStyle: UIAlertController.Style,
        actions: (title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?)...
    ) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        actions.forEach { actionInfo in
            let action = UIAlertAction(title: actionInfo.title, style: actionInfo.style, handler: actionInfo.handler)
            alert.addAction(action)
        }
        return alert
    }
}



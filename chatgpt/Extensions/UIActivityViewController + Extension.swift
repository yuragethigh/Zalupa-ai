//
//  UIActivityViewController + Extension.swift
//  chatgpt
//
//  Created by Yuriy on 15.01.2025.
//

import UIKit

extension UIActivityViewController {
    static func present(viewController: UIViewController, activityItems: [Any]) {
        let textShare = activityItems
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = viewController.view
        viewController.present(activityViewController, animated: true, completion: nil)
    }
}

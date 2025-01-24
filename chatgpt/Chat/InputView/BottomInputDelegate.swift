//
//  BottomInputDelegate.swift
//  chatgpt
//
//  Created by Yuriy on 13.01.2025.
//

import UIKit

protocol BottomInputDelegate: AnyObject {
    func sendButtonAction(_ text: String?, _ image: UIImage?)
    func requestMicPermissionAction()
    func presentBottomSheetAction()
    func addImageButtonAction()
    func stopGenerateAction()
}

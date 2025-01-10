//
//  ImagePicker.swift
//  chatgpt
//
//  Created by Yuriy on 09.01.2025.
//

import UIKit

protocol ImagePickerDelegate: AnyObject {
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage)
    func cancelButtonDidClick(on imagePicker: ImagePicker)
}

final class ImagePicker: NSObject {
    
    // MARK: - Properties
    private weak var controller: UIImagePickerController?
    weak var delegate: ImagePickerDelegate?
    
    // MARK: - Public Methods
    
    func dismiss() {
        controller?.dismiss(animated: true, completion: nil)
    }
    
    func present(
        from viewController: UIViewController,
        sourceType: UIImagePickerController.SourceType,
        allowsEditing: Bool = false
    ) {
        
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = allowsEditing
        imagePickerController.videoQuality = .typeIFrame1280x720
        self.controller = imagePickerController
        
        DispatchQueue.main.async {
            viewController.present(imagePickerController, animated: true, completion: nil)
        }
    }
}




// MARK: - UIImagePickerControllerDelegate
extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            delegate?.imagePicker(self, didSelect: editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            delegate?.imagePicker(self, didSelect: originalImage)
        } else {
            print("Image source not recognized")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.cancelButtonDidClick(on: self)
    }
}

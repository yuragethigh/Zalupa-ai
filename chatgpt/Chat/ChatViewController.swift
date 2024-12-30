//
//  ChatViewController.swift
//  chatgpt
//
//  Created by Yuriy on 27.12.2024.
//

import UIKit

final class ChatViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
    }
    
    @objc func close() {
        dismiss(animated: true)
    }
}

//
//  Untitled.swift
//  chatgpt
//
//  Created by Yuriy on 02.01.2025.
//

import UIKit
import SwiftUI

final class BannerTVCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = String(describing: BannerTVCell.self)

    private let insideView: UIView = {
        let insideView = UIView()
        insideView.backgroundColor = .clear
        insideView.translatesAutoresizingMaskIntoConstraints = false
        return insideView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setupConstraints() {
        contentView.addSubview(insideView)
        NSLayoutConstraint.activate([
            insideView.topAnchor.constraint(equalTo: contentView.topAnchor),
            insideView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            insideView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            insideView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Public Methods
    
    func configure(_ view: AnyView) {
        let host = UIHostingController(rootView: view)
        insideView.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.layer.cornerRadius = 16
        host.view.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: insideView.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: insideView.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: insideView.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: insideView.trailingAnchor)

        ])
    }

}


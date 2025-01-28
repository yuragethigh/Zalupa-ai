//
//  PlaceholderCollectionView.swift
//  chatgpt
//
//  Created by Yuriy on 27.01.2025.
//

import UIKit

protocol ChatPlaceholderDelegate: AnyObject {
    func didSelectItem(from item: Clues)
}


final class PlaceholderCollectionView: UICollectionView {
    
    private var clues = [Clues]()
    weak var chatPlaceholderDelegate: ChatPlaceholderDelegate?
    
    // MARK: - Initializers
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout = CenteredFlowLayout()
        layout.minimumInteritemSpacing = 14
        layout.minimumLineSpacing = 18
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        super.init(frame: .zero, collectionViewLayout: layout)
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        delegate = self
        dataSource = self
        register(
            ChatPlaceholderCVCell.self,
            forCellWithReuseIdentifier: ChatPlaceholderCVCell.identifier
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initializers
    
    
    // MARK: - Public methods
    
    func configure(clues: [Clues]) {
        self.clues = clues
    }
    
}

extension PlaceholderCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        clues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChatPlaceholderCVCell.identifier,
            for: indexPath
        ) as? ChatPlaceholderCVCell else {
            return UICollectionViewCell()
        }
        let item = clues[indexPath.item]
        cell.config(item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedItem = clues[indexPath.item]
        chatPlaceholderDelegate?.didSelectItem(from: selectedItem)
        print("Selected item: \(selectedItem)")
        
    }
}

//
//  HorizontalTableViewCell.swift
//  chatgpt
//
//  Created by Yuriy on 26.12.2024.
//

import UIKit

final class HorizontalTVCell: UITableViewCell {
    
    static let id = String(describing: HorizontalTVCell.self)
    
    private let collectionView: UICollectionView = {
        let layout = CustomHorizontalFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 257, height: 407 + 32 + 10)
        layout.minimumLineSpacing = -5
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = false
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(
            HorizontalCollectionViewCell.self,
            forCellWithReuseIdentifier: HorizontalCollectionViewCell.id
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let multiplier = 20
    private var models: [CollectionCellConfig]
    private var isPremium = false
    
    weak var delegate: SelectItemDelegate?
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        self.models = []
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )
        backgroundColor = .clear
        setCollectionViewDelegate()
        setupConstraints()
    }
    
    //MARK: - Public methods
    
    func configure(with items: [CollectionCellConfig], isPremium: Bool) {
        self.models = items
        self.isPremium = isPremium
        if !items.isEmpty {
            collectionView.reloadData()
            initialCenter()
        }
    }
    
    // MARK: Private methods
    
    private func initialCenter() {
        DispatchQueue.main.async {
            let middleIndexPath = IndexPath(item: (self.models.count * self.multiplier) / 2, section: 0)
            self.collectionView.scrollToItem(at: middleIndexPath, at: .centeredHorizontally, animated: false)
            
            self.layoutIfNeeded()
            self.updateVisibleCells()
        }
    }
    
    private func setCollectionViewDelegate() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupConstraints() {
        contentView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - UICollectionViewDelegate


extension HorizontalTVCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedModel = models[indexPath.row % models.count]
        delegate?.collectionTableViewCell(didSelectItem: selectedModel)
    }
}


//MARK: - UICollectionViewDelegateFlowLayout / UICollectionViewDataSource

extension HorizontalTVCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return models.count * multiplier
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HorizontalCollectionViewCell.id,
            for: indexPath
        ) as? HorizontalCollectionViewCell else {
            return UICollectionViewCell()
        }
        let currentCell = models[indexPath.row % models.count]
        let isCentered = indexPath.item == currentCenteredIndex()
        let currentImage = currentCell.isPremium ? currentCell.imageLocked : currentCell.imageDefault

        cell.configure(
            imageUrl: isPremium ? currentCell.imageDefault : currentImage,
            description: currentCell.description,
            isCentered: isCentered
        )
        return cell
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetX = scrollView.contentOffset.x
        let contentWidth = scrollView.contentSize.width
        let width = scrollView.bounds.size.width
        
        if currentOffsetX < width {
            let middleOffset = contentWidth / 2
            scrollView.contentOffset = CGPoint(x: middleOffset, y: scrollView.contentOffset.y)
        } else if currentOffsetX > contentWidth - width {
            let middleOffset = contentWidth / 2
            scrollView.contentOffset = CGPoint(x: middleOffset, y: scrollView.contentOffset.y)
        }
        
        hideAllCells()
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let width = layout.itemSize.width
        let spacing = layout.minimumLineSpacing

        let centerOffsetX = targetContentOffset.pointee.x + scrollView.bounds.size.width / 2
        
        let closestIndex = round((centerOffsetX - width / 2) / (width + spacing))
        
        let adjustedOffsetX = closestIndex * (width + spacing) + width / 2 - scrollView.bounds.size.width / 2
        
        targetContentOffset.pointee.x = adjustedOffsetX
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateVisibleCells()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideAllCells()
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        if !decelerate {
            updateVisibleCells()
        }
    }

    private func hideAllCells() {
        for cell in collectionView.visibleCells {
            if let customCell = cell as? HorizontalCollectionViewCell {
                customCell.hide()
            }
        }
    }

    private func updateVisibleCells() {
        guard let centeredIndex = currentCenteredIndex() else { return }

        for cell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell),
               let customCell = cell as? HorizontalCollectionViewCell {
                
                let isCentered = indexPath.item % models.count == centeredIndex
                let currentCell = models[indexPath.row % models.count]
                let currentImage = currentCell.isPremium ? currentCell.imageLocked : currentCell.imageDefault
               
                customCell.configure(
                    imageUrl: isPremium ? currentCell.imageDefault : currentImage,
                    description:currentCell.description,
                    isCentered: isCentered
                )
            }
        }
    }
    
    private func currentCenteredIndex() -> Int? {
        let visibleRect = CGRect(
            origin: collectionView.contentOffset,
            size: collectionView.bounds.size
        )
        let horizontalCenter = visibleRect.midX

        guard
            let closestIndexPath = collectionView.indexPathsForVisibleItems
                .min(by: { abs(collectionView.layoutAttributesForItem(at: $0)!.center.x - horizontalCenter) < abs(collectionView.layoutAttributesForItem(at: $1)!.center.x - horizontalCenter) })
        else {
            return nil
        }
        return closestIndexPath.item % models.count
    }
}

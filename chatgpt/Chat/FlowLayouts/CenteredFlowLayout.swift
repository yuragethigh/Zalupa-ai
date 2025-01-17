//
//  TestVC.swift
//  chatgpt
//
//  Created by Yuriy on 14.01.2025.
//

import UIKit

final class CenteredFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributesArray = super.layoutAttributesForElements(in: rect)?.map({ $0.copy() as! UICollectionViewLayoutAttributes }) else {
            return nil
        }
        
        var rows: [[UICollectionViewLayoutAttributes]] = []
        var currentRowY: CGFloat = -1
        var currentRow: [UICollectionViewLayoutAttributes] = []

        for attr in attributesArray {
            if abs(attr.frame.origin.y - currentRowY) > 1 {
                if !currentRow.isEmpty {
                    rows.append(currentRow)
                }
                currentRow = [attr]
                currentRowY = attr.frame.origin.y
            } else {
                currentRow.append(attr)
            }
        }
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }

        guard let collectionView = collectionView else { return attributesArray }
        for row in rows {
            let totalInteritemSpacing = CGFloat(row.count - 1) * minimumInteritemSpacing
            let totalCellWidth = row.reduce(0) { $0 + $1.frame.width }
            let rowWidth = totalCellWidth + totalInteritemSpacing
            let inset = (collectionView.bounds.width - rowWidth) / 2.0
            var currentX = inset

            for attr in row {
                var frame = attr.frame
                frame.origin.x = currentX
                attr.frame = frame
                currentX += frame.width + minimumInteritemSpacing
            }
        }
        
        return attributesArray
    }
}


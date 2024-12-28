//
//  CustomHorizontalFlowLayout.swift
//  chatgpt
//
//  Created by Yuriy on 26.12.2024.
//

import UIKit

final class CustomHorizontalFlowLayout: UICollectionViewFlowLayout {
    private let minScale: CGFloat = 0.3
    private let maxScale: CGFloat = 1.0

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView,
              let attributesList = super.layoutAttributesForElements(in: rect) else { return nil }

        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let horizontalCenter = visibleRect.midX

        attributesList.forEach { attributes in
            let distance = abs(attributes.center.x - horizontalCenter)
            let scale = max(maxScale - (distance / collectionView.bounds.width) * minScale, minScale)

            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)

            let scaledHeight = attributes.size.height * scale
            let originalHeight = attributes.size.height
            let yOffset = (originalHeight - scaledHeight) / 2

            attributes.center.y += yOffset
        }

        return attributesList
    }

    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }

        let targetRect = CGRect(
            x: proposedContentOffset.x,
            y: 0,
            width: collectionView.frame.width,
            height: collectionView.frame.height
        )
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude

        guard let attributesList = super.layoutAttributesForElements(in: targetRect) else {
            return proposedContentOffset
        }

        for attributes in attributesList {
            let itemHorizontalCenter = attributes.center.x
            if abs(itemHorizontalCenter - horizontalCenter) < abs(offsetAdjustment) {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        let newOffset = CGPoint(
            x: proposedContentOffset.x + offsetAdjustment,
            y: proposedContentOffset.y
        )
        
        return newOffset
    }
}

//
//  SnappingCollectionViewLayout.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 19/07/2024.
//

import UIKit


class SnappingCollectionViewLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        var attributesCopy = [UICollectionViewLayoutAttributes]()
        for itemAttributes in attributes {
            if let itemAttributesCopy = itemAttributes.copy() as? UICollectionViewLayoutAttributes {
                cellClosestToCenterWillBeProminent(attribute: itemAttributesCopy)
                attributesCopy.append(itemAttributesCopy)
            }
        }
        return attributesCopy
    }
    
    func cellClosestToCenterWillBeProminent(attribute: UICollectionViewLayoutAttributes) {
        
        guard let collectionView else {
            return
        }
        
        let collectionCenter = collectionView.frame.size.width / 2
        let offset = collectionView.contentOffset.x
        let normalizedCenter = attribute.center.x - offset
        let maxDistance = self.itemSize.width + self.minimumLineSpacing
        
        let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
        let ratio = (maxDistance - distance) / maxDistance
        let standardItemScale: CGFloat = 0.75
        let scale = min(ratio * (1 - standardItemScale) + standardItemScale, 1.0)
        attribute.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
}

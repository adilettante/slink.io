//
//  PHTPreviewLayout.swift
//  photto
//
//  Created by Tigran on 3/22/16.
//  Copyright © 2016 Simplitial. All rights reserved.
//

import UIKit

class HomeVCLayout: UICollectionViewFlowLayout {

	override func prepare() {
        super.prepare()
        if let collectionView = self.collectionView {
            var viewWidth = collectionView.bounds.size.width
            let itemsPerRow = floor(viewWidth / 100)
            viewWidth -= (itemsPerRow + 1) * minimumInteritemSpacing
            let itemDimension = viewWidth / itemsPerRow
            // Set the new item size
            itemSize = CGSize(width: itemDimension, height: itemDimension)
        }
    }
}

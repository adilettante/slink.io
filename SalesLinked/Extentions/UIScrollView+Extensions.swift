//
//  UIScrollView+Extensions.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 10/3/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    func  isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}

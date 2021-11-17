//
//  RoundedView.swift
//  SalesLinked
//
//  Created by Yervand Saribekyan on 1/19/18.
//  Copyright © 2018 STDev. All rights reserved.
//

import UIKit

class RoundedView: UIView {

    @IBInspectable
    public var viewCornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = viewCornerRadius
            layer.masksToBounds = true
        }
    }

}

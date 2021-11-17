//
//  CustomButton.swift
//  SalesLinked
//
//  Created by STDev Mac on 6/26/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit

@IBDesignable
class BaseCustomButton: UIButton {

    @IBInspectable var cornerRadius: Double {
        get {
            return Double(self.layer.cornerRadius)
        }
        set {
            self.layer.cornerRadius = CGFloat(newValue)
        }
    }
}

//
//  ShadowContainer.swift
//  AmvigoEliteClient
//
//  Created by STDev's Mac Mini 2 on 8/2/17.
//  Copyright © 2017 STDev's Mac Mini 2. All rights reserved.
//

import UIKit

class ShadowContainer: UIView {

	@IBInspectable
	public var shadowColor: UIColor = UIColor.black {
		didSet {
			self.layer.shadowColor = shadowColor.cgColor
		}
	}

	@IBInspectable
	public var shadowOffset: CGSize = CGSize.zero {
		didSet {
			self.layer.shadowOffset = shadowOffset
		}
	}

	@IBInspectable
	public var isRounded: Bool = false

	@IBInspectable
	public var shadowRadius: CGFloat = 0 {
		didSet {
			self.layer.shadowRadius = shadowRadius
		}
	}

	@IBInspectable
	public var shadowOpacity: Float = 1.0 {
		didSet {
			self.layer.shadowOpacity = shadowOpacity
		}
	}

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
		if isRounded {
			shadowRadius = rect.size.height / 2
			let newRect = CGRect(origin: rect.origin,
								 size: CGSize(width: rect.width, height: rect.height))
			self.layer.shadowPath = UIBezierPath(rect: newRect).cgPath
		} else {
			self.layer.shadowPath = UIBezierPath(rect: rect).cgPath
		}
		self.layer.shouldRasterize = true

		self.layer.masksToBounds = false
		self.layer.rasterizationScale = UIScreen.main.scale
    }

}

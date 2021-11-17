//
//  Theme.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 10/9/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import SwiftHEXColors

enum Themes {
    case Default
}

struct Theme {

    static let theme: Themes = .Default

    private static let allStyles = [

        Themes.Default: (
            mainColor: UIColor(hex: 0x1e4f7a)!,
            secondaryColor: UIColor(hex: 0x666666)!,
            separatorColor: UIColor(hex: 0xd1dadf)!,
            grayBg: UIColor(hex: 0xedeef1)!,
            defaultPlaceholderImage: UIImage()
        )
    ]

    public static var styles = {
        return allStyles[theme]!
    }

}

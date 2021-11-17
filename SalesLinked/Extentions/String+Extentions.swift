//
//  String+Extentions.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 10/9/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import UIKit

extension String {

    func toUrl() -> URL? {
        return URL(string: self)
    }

    var toUIImage: UIImage? {
        guard let url = self.toUrl(), let data = try? Data(contentsOf: url)  else { return nil }
        return UIImage(data: data)
    }
}

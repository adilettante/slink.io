//
//  CustomCache.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 10/5/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import AlamofireImage

class CustomCache: AutoPurgingImageCache {
    override func imageCacheKey(for request: URLRequest, withIdentifier identifier: String?) -> String {
        return (request.url?.path)!
    }
}

//
//  Bundle+Extensions.swift
//  SalesLinked
//
//  Created by Tigran Hambardzumyan on 4/25/18.
//  Copyright © 2018 STDev. All rights reserved.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

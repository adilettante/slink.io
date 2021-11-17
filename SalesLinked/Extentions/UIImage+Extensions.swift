//
//  UIImage+Extensions.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 10/2/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit

enum UIImageError: Error {
    case JPEGRepresentationFailed
}

extension UIImage {

    func saveToDir(with name: String? = nil, compressionQuality: CGFloat = 0.7) throws -> URL {

        var fileName: String
        if let name = name {
            fileName = name
        } else {
            fileName = "copy"
        }

        if let data = UIImageJPEGRepresentation(self, compressionQuality) {
            let filename = getDocumentsDirectory().appendingPathComponent(fileName.appending(".jpg"))
            try? data.write(to: filename)
            return filename
        }
        throw UIImageError.JPEGRepresentationFailed
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

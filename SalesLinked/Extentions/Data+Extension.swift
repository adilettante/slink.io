//
//  DataExtension.swift
//  SalesLinked
//
//  Created by STDev Mac on 7/18/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import UIKit

extension Data {

    func saveDataAsImage(resizeImage: Bool = false,
                         imgName: String? = nil,
                         folderName: String? = nil) -> (original: URL, thumbnail: URL?)? {
        let fileManager = FileManager.default
		guard let documentsURL = fileManager.containerURL(
				forSecurityApplicationGroupIdentifier: groupName
            ) else { return nil }
		let fileName = imgName ?? UUID().uuidString
        var dictPath = documentsURL
        if let folder = folderName {
            dictPath = dictPath.appendingPathComponent(folder, isDirectory: true)
            try? fileManager.createDirectory(atPath: dictPath.path, withIntermediateDirectories: true)
        }

		let originalImageUrl = dictPath.appendingPathComponent("\(fileName).jpg")
		try? self.write(to: originalImageUrl, options: .atomic)
        var thumbUrl: URL? = nil
		if resizeImage {
			if let image = UIImage(data: self) {
                let tumbImage = image.aspectFill(width: 400, height: 400) ?? image
				let data = UIImageJPEGRepresentation(tumbImage, 0.7)
                thumbUrl = data?.saveDataAsImage(imgName: "\(fileName).thumb", folderName: folderName)?.original
			}
		}
        return (original: originalImageUrl, thumbnail: thumbUrl)
    }
}

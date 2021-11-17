//
//  UIImageVIew+Extention.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 10/9/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {

    static let placeholderImage = Theme.styles().defaultPlaceholderImage

    func ra_setImage(_ url: URL?) {
        self.image = UIImage()
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        self.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = UIColor.black
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicator.hidesWhenStopped = true
        self.sd_setImage(
            with: url,
            placeholderImage: Theme.styles().defaultPlaceholderImage,
            options: [
                .continueInBackground,
                .retryFailed,
                .refreshCached,
                .highPriority
        ]) { (image, _, _, _) in
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            self.image = image ?? Theme.styles().defaultPlaceholderImage
        }
    }

    func ra_setImage(string: String?) {
        self.ra_setImage(string?.toUrl())
    }
}

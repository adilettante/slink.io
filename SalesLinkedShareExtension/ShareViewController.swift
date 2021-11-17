//
//  ShareViewController.swift
//  SalesLinkedShereExtension
//
//  Created by STDev Mac on 6/2/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import RealmSwift

class ShareViewController: SLComposeServiceViewController {

    private let contentType = kUTTypeImage as String
    var imageData = [Data]()
    var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Reset Post button text.
        for item in (self.navigationController?.navigationBar.items)! {
            if let rightItem = item.rightBarButtonItem {
                rightItem.title = "Import"
                break
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let count = textView.superview?.superview?.subviews[2].subviews.count, count > 1 {
            self.textView.isHidden = true
        }
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    // Called after the user selects an image from the photos
    override func didSelectPost() {
        // This is called after the user selects Post.
        // Make sure we have a valid extension item
        guard extensionContext?.inputItems.count ?? 0 > 0 else {
            let error = NSError(domain: "Input items are empty", code: 4000, userInfo: nil)
            self.extensionContext?.cancelRequest(withError: error)
            return
        }

        guard let content = extensionContext!.inputItems.first as? NSExtensionItem else {
            let error = NSError(domain: "Input items are empty", code: 4001, userInfo: nil)
            self.extensionContext?.cancelRequest(withError: error)
            return
        }

        // Verify the provider is valid
        guard let contents = content.attachments as? [NSItemProvider] else {
            let error = NSError(domain: "Provider is invalid", code: 4002, userInfo: nil)
            self.extensionContext?.cancelRequest(withError: error)
            return
        }
        // look for pdfs
        self.count = contents.count
        for attachment in contents where attachment.hasItemConformingToTypeIdentifier(contentType) {
            attachment.loadItem(forTypeIdentifier: contentType, options: nil) { [weak self] data, _ in
                self?.count -= 1
                if let url = data as? URL,
                    let imageData = try? Data(contentsOf: url),
                    let images =  imageData.saveDataAsImage(resizeImage: true, folderName: imagesFolderName) {

                    let cardInfo = BusinessCardInfo(
                        image: images.original.absoluteString,
                        thumbnail: images.thumbnail?.absoluteString,
                        note: self?.contentText ?? "")
                    RealmService.shared.addBusinessCard(cardInfo)
                }
                if self?.count ?? 0 == 0 {
                    self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: { (_) in
                    })
                }
            }
        }
    }
}

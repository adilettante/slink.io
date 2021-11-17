//
//  PolicyViewController.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 10/17/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit

class PolicyViewController: BaseViewController, UITextViewDelegate {
    @IBOutlet weak var policyTextPlain: UITextView!

    private let urlString = "App Privacy Policy Generator"
    private let url = "https://app-privacy-policy-generator.firebaseapp.com/"

    override func viewDidLoad() {
        super.viewDidLoad()
        policyTextPlain.scrollRangeToVisible(NSRange(location: 0, length: 0))
        initTextView()
    }

    private func initTextView() {
        let attributedString = NSMutableAttributedString(attributedString: policyTextPlain.attributedText)
        let linkRange = (attributedString.string as NSString).range(of: urlString)
        attributedString.addAttribute(NSAttributedStringKey.link, value: url, range: linkRange)
        policyTextPlain.attributedText = attributedString
    }
}

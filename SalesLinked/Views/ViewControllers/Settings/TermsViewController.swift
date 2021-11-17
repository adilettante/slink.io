//
//  TermsViewController.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 9/28/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit

class TermsViewController: BaseViewController {
    @IBOutlet weak var termsTextPlain: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        termsTextPlain.scrollRangeToVisible(NSRange(location: 0, length: 0))
    }

}

//
//  SettingsStandardTableViewCell.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 9/28/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit

class SettingsStandardTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var cellMargin: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

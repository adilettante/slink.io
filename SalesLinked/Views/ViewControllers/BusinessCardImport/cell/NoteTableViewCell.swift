//
//  NoteTableViewCell.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 10/5/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var largeBottomMargin: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  DeleteTableViewCell.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 11/15/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit

class DeleteCell: UICollectionViewCell {
    @IBOutlet weak var deleteImage: UIImageView!
    @IBOutlet weak var pickButton: UIButton!

    weak var delegate: DeleteContactsViewControllerDelegate?

    var id = ""

    @IBAction func selectImage(_ sender: Any) {
        pickButton.isSelected = !pickButton.isSelected
        delegate?.itemSelected(id: id, selected: pickButton.isSelected)
    }
}

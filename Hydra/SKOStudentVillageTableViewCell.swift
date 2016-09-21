//
//  SKOStudentVillageTableViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

class SKOStudentVillageTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var logoView: UIImageView?
    @IBOutlet var contentLabel: UILabel?
    @IBOutlet var boothLabel: UILabel?
    @IBOutlet var categoryLabel: UILabel?

    var exihibitor: Exihibitor? {
        didSet {
            if let exihibitor = exihibitor {
                nameLabel?.text = exihibitor.name
                if let url = NSURL(string: exihibitor.logo) {
                    logoView?.sd_setImageWithURL(url)
                }
                contentLabel?.text = exihibitor.content
            }
        }
    }
}

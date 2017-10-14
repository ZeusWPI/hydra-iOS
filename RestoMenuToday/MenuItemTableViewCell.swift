//
//  MenuItemTableViewCell.swift
//  Hydra
//
//  Created by Simon Schellaert on 12/11/14.
//  Copyright (c) 2014 Simon Schellaert. All rights reserved.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {
    
    // MARK: Interface Builder Outlets
    
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    
    var menuItem : RestoMenuItem? {
        didSet {
            self.nameLabel?.text = menuItem?.name
            self.priceLabel?.text = menuItem?.price
        }
    }
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

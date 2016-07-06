//
//  UIViewExtension.swift
//  Hydra
//
//  Created by Timo De Waele on 06/07/16.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import UIKit

extension UIView {
    
    func setShadow() {
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowRadius = 7
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSizeMake(7, 7)
    }
}

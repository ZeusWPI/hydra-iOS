//
//  UIViewExtension.swift
//  Hydra
//
//  Created by Timo De Waele on 06/07/16.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import UIKit

extension UIView {

    @IBInspectable var border: Bool {
        get {
            return layer.cornerRadius > 0 && layer.borderWidth > 0
        }
        set {
            if newValue {
                layer.cornerRadius = 5
                layer.borderWidth = 1
                layer.borderColor = UIColor.whiteColor().CGColor
            } else {
                layer.cornerRadius = 0
                layer.borderWidth = 0
            }
            layer.masksToBounds = layer.cornerRadius > 0
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(CGColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.CGColor
        }
    }

    func setShadow() {
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowRadius = 7
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSizeMake(7, 7)
    }
}

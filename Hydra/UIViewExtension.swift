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
                layer.borderColor = UIColor.white.cgColor
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
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    func setShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 7
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSize(width: 7, height: 7)
    }
}

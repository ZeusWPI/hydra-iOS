//
//  String.swift
//  Hydra
//
//  Created by Simon Schellaert on 14/11/14.
//  Copyright (c) 2014 Simon Schellaert. All rights reserved.
//

import Foundation

extension String {
    /** 
    A representation of the receiver with the first character capitalized. (read-only)
    */
    var sentenceCapitalizedString : NSString {
        if !self.isEmpty {
            let first = String(self.prefix(1)).capitalized
            let other = String(self.dropFirst())
            return (first + other) as NSString
        } else {
            return self as NSString
        }
    }
}

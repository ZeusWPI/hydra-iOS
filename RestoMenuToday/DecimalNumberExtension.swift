//
//  DecimalNumberExtension.swift
//  Hydra
//
//  Created by Simon Schellaert on 11/11/14.
//  Copyright (c) 2014 Simon Schellaert. All rights reserved.
//

import Foundation

extension NSDecimalNumber {
    
    /**
    Creates and returns an NSDecimalNumber object whose value is equivalent to that in a given numeric string.
    All non-numerical characters are automatically stripped from the given string.
    */
    convenience init(euroString : String) {
        // Replace the comma by a point since the NSDecimalNumber expects a point as decimal separator
        var euroString = euroString.replacingOccurrences(of: ",", with: ".", options: [], range: nil)

        // Remove any non-numerical characters
        let charactersToRemove = CharacterSet(charactersIn: "0123456789.").inverted
        euroString = euroString.components(separatedBy: charactersToRemove).joined(separator: "")
        
        self.init(string: euroString)
    }
    
}

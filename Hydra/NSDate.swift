//
//  NSDate.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 05/04/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }
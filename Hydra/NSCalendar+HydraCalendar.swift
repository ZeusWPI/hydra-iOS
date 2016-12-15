//
//  NSCalendar+HydraCalendar.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/2015.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation

extension Calendar {

    static func hydraCalendar() -> Calendar {
        return Calendar(identifier: Calendar.Identifier.iso8601)
    }
}

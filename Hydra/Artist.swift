//
//  Artist.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 10/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class Artist: NSObject, Codable {
    var name: String = ""
    var start: Date = Date(timeIntervalSince1970: 0)
    var end: Date = Date(timeIntervalSince1970: 0)
    var picture: String?

    private enum CodingKeys: String, CodingKey {
        case name = "artist"
        case start, end, picture
    }
}

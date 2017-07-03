//
//  SpecialEvent.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 04/04/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper

class SpecialEvent: NSObject, Codable {

    var name: String
    var link: String
    var simpleText: String
    var image: String
    var priority: Int
    var start: Date
    var end: Date
    var html: String?
    var development: Bool

    required init(name: String, link: String, simpleText: String, image: String, priority: Int, start: Date, end: Date, development: Bool, html: String? = nil) {
        self.name = name
        self.link = link
        self.simpleText = simpleText
        self.image = image
        self.priority = priority
        self.start = start
        self.end = end
        self.development = development
        self.html = html
    }

    private enum CodingKeys: String, CodingKey {
        case name, link, image, priority, start, end, html, development
        case simpleText = "simple-text"
    }

}

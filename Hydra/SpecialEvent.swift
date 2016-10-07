//
//  SpecialEvent.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 04/04/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper

class SpecialEvent: NSObject, NSCoding, Mappable {

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

    //MARK: NSCoding
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as? String,
            let link = aDecoder.decodeObject(forKey: PropertyKey.linkKey) as? String,
            let simpleText = aDecoder.decodeObject(forKey: PropertyKey.simpleTextKey) as? String,
            let image = aDecoder.decodeObject(forKey: PropertyKey.imageKey) as? String,
            let start = aDecoder.decodeObject(forKey: PropertyKey.startKey) as? Date,
            let end = aDecoder.decodeObject(forKey: PropertyKey.endKey) as? Date
            else {
                return nil
        }

        let priority = aDecoder.decodeInteger(forKey: PropertyKey.priorityKey)
        let html = aDecoder.decodeObject(forKey: PropertyKey.htmlKey) as? String
        let develoment = aDecoder.decodeBool(forKey: PropertyKey.developmentKey)

        self.init(name: name, link: link, simpleText: simpleText, image: image, priority: priority, start: start, end: end, development: develoment, html: html)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(link, forKey: PropertyKey.linkKey)
        aCoder.encode(simpleText, forKey: PropertyKey.simpleTextKey)
        aCoder.encode(image, forKey: PropertyKey.imageKey)
        aCoder.encode(priority, forKey: PropertyKey.priorityKey)
        aCoder.encode(start, forKey: PropertyKey.startKey)
        aCoder.encode(end, forKey: PropertyKey.endKey)
        aCoder.encode(development, forKey: PropertyKey.developmentKey)
        aCoder.encode(html, forKey: PropertyKey.htmlKey)
    }

    //MARK: Mapping
    required convenience init?(map: Map) {
        self.init(name: "", link: "", simpleText: "", image: "", priority: 0, start: Date(), end: Date(), development: false)
    }

    func mapping(map: Map) {
        name <- map[PropertyKey.nameKey]
        link <- map[PropertyKey.linkKey]
        simpleText <- map[PropertyKey.simpleTextKey]
        image <- map[PropertyKey.imageKey]
        priority <- map[PropertyKey.priorityKey]
        start <- (map[PropertyKey.startKey], ISO8601DateTransform())
        end <- (map[PropertyKey.endKey], ISO8601DateTransform())
        development <- map[PropertyKey.developmentKey]
        html <- map[PropertyKey.htmlKey]
    }


    struct PropertyKey {
        static let nameKey = "name"
        static let linkKey = "link"
        static let simpleTextKey = "simple-text"
        static let imageKey = "image"
        static let priorityKey = "priority"
        static let startKey = "start"
        static let endKey = "end"
        static let htmlKey = "html"
        static let developmentKey = "development"
    }

}

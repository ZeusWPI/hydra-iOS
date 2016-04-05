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
    var start: NSDate
    var end: NSDate
    var html: String?
    var development: Bool

    required init(name: String, link: String, simpleText: String, image: String, priority: Int, start: NSDate, end: NSDate, development: Bool, html: String? = nil) {
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
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let link = aDecoder.decodeObjectForKey(PropertyKey.linkKey) as! String
        let simpleText = aDecoder.decodeObjectForKey(PropertyKey.simpleTextKey) as! String
        let image = aDecoder.decodeObjectForKey(PropertyKey.imageKey) as! String
        let priority = aDecoder.decodeObjectForKey(PropertyKey.priorityKey) as! Int
        let start = aDecoder.decodeObjectForKey(PropertyKey.startKey) as! NSDate
        let end = aDecoder.decodeObjectForKey(PropertyKey.endKey) as! NSDate
        let develoment = aDecoder.decodeObjectForKey(PropertyKey.developmentKey) as! Bool
        let html = aDecoder.decodeObjectForKey(PropertyKey.htmlKey) as? String

        self.init(name: name, link: link, simpleText: simpleText, image: image, priority: priority, start: start, end: end, development: develoment, html: html)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(link, forKey: PropertyKey.linkKey)
        aCoder.encodeObject(simpleText, forKey: PropertyKey.simpleTextKey)
        aCoder.encodeObject(image, forKey: PropertyKey.imageKey)
        aCoder.encodeObject(priority, forKey: PropertyKey.priorityKey)
        aCoder.encodeObject(start, forKey: PropertyKey.startKey)
        aCoder.encodeObject(end, forKey: PropertyKey.endKey)
        aCoder.encodeObject(development, forKey: PropertyKey.developmentKey)
        aCoder.encodeObject(html, forKey: PropertyKey.htmlKey)
    }

    //MARK: Mapping
    required convenience init?(_ map: Map) {
        self.init(name: "", link: "", simpleText: "", image: "", priority: 0, start: NSDate(), end: NSDate(), development: false)
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
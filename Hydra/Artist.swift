//
//  Artist.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 10/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper

class Artist: NSObject, NSCoding, Mappable {
    var name: String = ""
    var start: NSDate = NSDate(timeIntervalSince1970: 0)
    var end: NSDate = NSDate(timeIntervalSince1970: 0)
    var picture: String?

    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObjectForKey(name) as? String,
        let start = aDecoder.decodeObjectForKey(PropertyKey.startKey) as? NSDate,
            let end = aDecoder.decodeObjectForKey(PropertyKey.endKey) as? NSDate else {
                return nil
        }

        self.name = name
        self.start = start
        self.end = end

        picture = aDecoder.decodeObjectForKey(PropertyKey.pictureKey) as? String
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(start, forKey: PropertyKey.startKey)
        aCoder.encodeObject(end, forKey: PropertyKey.endKey)
        aCoder.encodeObject(picture, forKey: PropertyKey.pictureKey)
    }

    required init?(_ map: Map) {

    }

    func mapping(map: Map) {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        let dateTransform = DateFormatterTransform(dateFormatter: formatter)
        name <- map["artist"]
        start <- (map[PropertyKey.startKey], dateTransform)
        end <- (map[PropertyKey.endKey], dateTransform)
        picture <- map[PropertyKey.pictureKey]
    }

    struct PropertyKey {
        static let nameKey = "name"
        static let startKey = "start"
        static let endKey = "end"
        static let pictureKey = "picture"
    }
}
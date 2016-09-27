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
    var start: Date = Date(timeIntervalSince1970: 0)
    var end: Date = Date(timeIntervalSince1970: 0)
    var picture: String?

    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: name) as? String,
        let start = aDecoder.decodeObject(forKey: PropertyKey.startKey) as? Date,
            let end = aDecoder.decodeObject(forKey: PropertyKey.endKey) as? Date else {
                return nil
        }

        self.name = name
        self.start = start
        self.end = end

        picture = aDecoder.decodeObject(forKey: PropertyKey.pictureKey) as? String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(start, forKey: PropertyKey.startKey)
        aCoder.encode(end, forKey: PropertyKey.endKey)
        aCoder.encode(picture, forKey: PropertyKey.pictureKey)
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
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

//
//  Calendar.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 30/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

import ObjectMapper

class CalendarItem: NSObject, Mappable, NSCoding {
    var title: String = ""
    var content: String?
    var startDate: NSDate = NSDate(timeIntervalSince1970: 0)
    var endDate: NSDate = NSDate(timeIntervalSince1970: 0)
    var location: String?
    var itemId: Int64 = 0
    var courseId: String = ""
    var creator: String?
    var created: NSDate = NSDate(timeIntervalSince1970: 0)

    var course: Course?

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.title, forKey: PropertyKey.titleKey)
        aCoder.encodeObject(self.content, forKey: PropertyKey.contentKey)
        aCoder.encodeObject(self.startDate, forKey: PropertyKey.startDateKey)
        aCoder.encodeObject(self.endDate, forKey: PropertyKey.endDateKey)
        aCoder.encodeObject(self.location, forKey: PropertyKey.locationKey)
        aCoder.encodeInt64(self.itemId, forKey: PropertyKey.itemIdKey)
        aCoder.encodeObject(self.courseId, forKey: PropertyKey.courseIdKey)
        aCoder.encodeObject(self.creator, forKey: PropertyKey.creatorKey)
        aCoder.encodeObject(self.created, forKey: PropertyKey.createdKey)
    }

    required init?(_ map: Map) {

    }

    required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObjectForKey(PropertyKey.titleKey) as! String
        self.content = aDecoder.decodeObjectForKey(PropertyKey.contentKey) as? String
        self.startDate = aDecoder.decodeObjectForKey(PropertyKey.startDateKey) as! NSDate
        self.endDate = aDecoder.decodeObjectForKey(PropertyKey.endDateKey) as! NSDate
        self.location = aDecoder.decodeObjectForKey(PropertyKey.locationKey) as? String
        self.itemId = aDecoder.decodeInt64ForKey(PropertyKey.itemIdKey)
        self.courseId = aDecoder.decodeObjectForKey(PropertyKey.courseIdKey) as! String
        self.creator = aDecoder.decodeObjectForKey(PropertyKey.creatorKey) as? String
        self.created = aDecoder.decodeObjectForKey(PropertyKey.createdKey) as! NSDate
    }

    func mapping(map: Map) {
        self.title <- map[PropertyKey.titleKey]
        self.content <- map[PropertyKey.contentKey]
        self.startDate <- (map[PropertyKey.startDateKey], ISO8601DateTransform())
        self.endDate <- (map[PropertyKey.endDateKey], ISO8601DateTransform())
        self.location <- map[PropertyKey.locationKey]
        self.itemId <- map[PropertyKey.itemIdKey]
        self.courseId <- map[PropertyKey.courseIdKey]
        self.creator <- map[PropertyKey.creatorKey]
        self.created <- (map[PropertyKey.createdKey], ISO8601DateTransform())
    }

    struct PropertyKey {
        static let titleKey = "title"
        static let contentKey = "content"
        static let startDateKey = "start_date"
        static let endDateKey = "end_date"
        static let locationKey = "location"
        static let itemIdKey = "item_id"
        static let courseIdKey = "course_id"
        static let creatorKey = "last_edit_user"
        static let createdKey = "last_edit_time"
    }
}
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
    var startDate: Date = Date(timeIntervalSince1970: 0)
    var endDate: Date = Date(timeIntervalSince1970: 0)
    var location: String?
    var itemId: Int64 = 0
    var courseId: String = ""
    var creator: String?
    var created: Date = Date(timeIntervalSince1970: 0)

    var course: Course? {
        get {
            return MinervaStore.sharedStore.course(courseId)
        }
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.title, forKey: PropertyKey.titleKey)
        aCoder.encode(self.content, forKey: PropertyKey.contentKey)
        aCoder.encode(self.startDate, forKey: PropertyKey.startDateKey)
        aCoder.encode(self.endDate, forKey: PropertyKey.endDateKey)
        aCoder.encode(self.location, forKey: PropertyKey.locationKey)
        aCoder.encode(self.itemId, forKey: PropertyKey.itemIdKey)
        aCoder.encode(self.courseId, forKey: PropertyKey.courseIdKey)
        aCoder.encode(self.creator, forKey: PropertyKey.creatorKey)
        aCoder.encode(self.created, forKey: PropertyKey.createdKey)
    }

    required init?(map: Map) {

    }

    required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: PropertyKey.titleKey) as! String
        self.content = aDecoder.decodeObject(forKey: PropertyKey.contentKey) as? String
        self.startDate = aDecoder.decodeObject(forKey: PropertyKey.startDateKey) as! Date
        self.endDate = aDecoder.decodeObject(forKey: PropertyKey.endDateKey) as! Date
        self.location = aDecoder.decodeObject(forKey: PropertyKey.locationKey) as? String
        self.itemId = aDecoder.decodeInt64(forKey: PropertyKey.itemIdKey)
        self.courseId = aDecoder.decodeObject(forKey: PropertyKey.courseIdKey) as! String
        self.creator = aDecoder.decodeObject(forKey: PropertyKey.creatorKey) as? String
        self.created = aDecoder.decodeObject(forKey: PropertyKey.createdKey) as! Date
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

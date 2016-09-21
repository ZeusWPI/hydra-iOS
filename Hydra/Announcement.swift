//
//  Announcement.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 21/06/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper

class Announcement: NSObject, Mappable, NSCoding {
    var title: String
    var content: String
    var emailSent: Bool
    var itemId: Int
    var editUser: String
    var date: NSDate
    private var _read: Bool

    var course: Course?

    var read: Bool {
        set {
            MinervaStore.sharedStore.saveLater()
            self._read = newValue
        }
        get {
            return self._read
        }
    }


    convenience required init?(_ map: Map) {
        self.init(title: "", content: "", emailSent: false, itemId: 0, editUser: "", date: NSDate(timeIntervalSince1970: 0))
    }

    init(title: String, content: String, emailSent: Bool, itemId: Int, editUser: String, date: NSDate, read: Bool = false) {
        self.title = title
        self.content = content
        self.emailSent = emailSent
        self.itemId = itemId
        self.editUser = editUser
        self.date = date
        self._read = read
    }

    func mapping(map: Map) {
        self.title <- map[PropertyKey.titleKey]
        self.content <- map[PropertyKey.contentKey]
        self.emailSent <- map[PropertyKey.emailSentKey]
        self.itemId <- map[PropertyKey.itemIdKey]
        self.editUser <- map[PropertyKey.editUserKey]
        self.date <- (map[PropertyKey.dateKey], ISO8601DateTransform())
    }

    required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObjectForKey(PropertyKey.titleKey) as! String
        self.content = aDecoder.decodeObjectForKey(PropertyKey.contentKey) as! String
        self.emailSent = aDecoder.decodeObjectForKey(PropertyKey.emailSentKey) as! Bool
        self.itemId = aDecoder.decodeObjectForKey(PropertyKey.itemIdKey) as! Int
        self.editUser = aDecoder.decodeObjectForKey(PropertyKey.editUserKey) as! String
        self.date = aDecoder.decodeObjectForKey(PropertyKey.dateKey) as! NSDate
        self._read = aDecoder.decodeBoolForKey(PropertyKey.readKey)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.title, forKey: PropertyKey.titleKey)
        aCoder.encodeObject(self.content, forKey: PropertyKey.contentKey)
        aCoder.encodeObject(self.emailSent, forKey: PropertyKey.emailSentKey)
        aCoder.encodeObject(self.itemId, forKey: PropertyKey.itemIdKey)
        aCoder.encodeObject(self.editUser, forKey: PropertyKey.editUserKey)
        aCoder.encodeObject(self.date, forKey: PropertyKey.dateKey)
        aCoder.encodeBool(self._read, forKey: PropertyKey.readKey)
    }

    struct PropertyKey {
        static let titleKey = "title"
        static let contentKey = "content"
        static let emailSentKey = "email_sent"
        static let itemIdKey = "item_id"
        static let editUserKey = "last_edit_user"
        static let dateKey = "last_edit_time"
        static let readKey = "read"
    }
}

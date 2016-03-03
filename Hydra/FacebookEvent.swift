//
//  FacebookEvent.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 03/03/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

@objc enum FacebookEventRsvp: Int {
    case None, Attending, Unsure, Declined
    func FacebookEventRsvpAsLocalizedString(eventRsvp: FacebookEventRsvp) -> String {
        switch(eventRsvp) {
        case .None:
            return ""
        case .Attending:
            return "aanwezig"
        case .Unsure:
            return "misschien"
        case .Declined:
            return "niet aanwezig"
        }
    }
}

class FacebookEvent: NSObject, NSCoding {
    var valid: Bool = false
    var smallImageUrl: NSURL?
    var largeImageUrl: NSURL?

    var attendees: UInt = 0
    var friendsAttending: [FacebookEventFriend]?
    var userRsvp: FacebookEventRsvp = .None
    var userRsvpUpdating = false

    private var eventId: String?
    private var lastUpdated: NSDate?

    init(eventId: String) {
        self.eventId = eventId
    }

    func update() {

    }

    func showExternally() {

    }

// MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        self.valid = aDecoder.decodeObjectForKey(PropertyKey.validKey) as! Bool
        self.smallImageUrl = aDecoder.decodeObjectForKey(PropertyKey.smallImageUrlKey) as? NSURL
        self.largeImageUrl = aDecoder.decodeObjectForKey(PropertyKey.largeImageUrlKey) as? NSURL

        self.attendees = aDecoder.decodeObjectForKey(PropertyKey.attendeesKey) as! UInt
        self.friendsAttending = aDecoder.decodeObjectForKey(PropertyKey.friendsAttendingKey) as? [FacebookEventFriend]
        self.userRsvp = FacebookEventRsvp(rawValue: aDecoder.decodeObjectForKey(PropertyKey.userRsvpKey) as! Int)!

        self.lastUpdated = aDecoder.decodeObjectForKey(PropertyKey.lastUpdatedKey) as? NSDate
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(valid, forKey: PropertyKey.validKey)
        aCoder.encodeObject(smallImageUrl, forKey: PropertyKey.smallImageUrlKey)
        aCoder.encodeObject(largeImageUrl, forKey: PropertyKey.largeImageUrlKey)

        aCoder.encodeObject(attendees, forKey: PropertyKey.attendeesKey)
        aCoder.encodeObject(friendsAttending, forKey: PropertyKey.friendsAttendingKey)
        aCoder.encodeObject(userRsvp.hashValue, forKey: PropertyKey.userRsvpKey)

        aCoder.encodeObject(lastUpdated, forKey: PropertyKey.lastUpdatedKey)
    }

    struct PropertyKey {
        static let validKey = "valid"
        static let smallImageUrlKey = "smallImageUrl"
        static let largeImageUrlKey = "largeImageUrl"
        static let attendeesKey = "attendees"
        static let friendsAttendingKey = "friendsAttending"
        static let userRsvpKey = "userRsvp"
        static let eventIdKey = "eventIdKey"
        static let lastUpdatedKey = "lastUpdated"
    }
}


class FacebookEventFriend: NSObject, NSCoding {
    var name: String
    var photoUrl: NSURL?

    init(name: String, photoUrl: NSURL?) {
        self.name = name
        self.photoUrl = photoUrl
    }

    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        self.photoUrl = aDecoder.decodeObjectForKey(PropertyKey.photoUrlKey) as? NSURL
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(photoUrl, forKey: PropertyKey.photoUrlKey)
    }

    struct PropertyKey {
        static let nameKey = "name"
        static let photoUrlKey = "photoUrl"
    }
}
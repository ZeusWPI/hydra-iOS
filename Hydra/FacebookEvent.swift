//
//  FacebookEvent.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 03/03/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import FBSDKLoginKit

let FacebookEventDidUpdateNotification = "FacebookEventDidUpdateNotification"

@objc enum FacebookEventRsvp: Int {
    case None, Attending, Unsure, Declined
    func localizedString() -> String {
        switch(self) {
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

    func graphRequestString() -> String? {
        switch(self) {
        case .Attending:
            return "attending"
        case .Unsure:
            return "unsure"
        case .Declined:
            return "declined"
        case .None:
            return nil
        }
    }
}

class FacebookEvent: NSObject, NSCoding {
    var valid: Bool = false
    var imageUrl: NSURL?

    var attendees: UInt = 0
    var friendsAttending: [FacebookEventFriend]?
    var userRsvp: FacebookEventRsvp = .None
    var userRsvpUpdating = false

    private var eventId: String
    private var lastUpdated: NSDate?

    init(eventId: String) {
        self.eventId = eventId

        super.init()

        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(FacebookEvent.facebookSessionStateChanged(_:)), name: FacebookSessionStateChangedNotification, object: nil)

        self.update()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func showExternally() {
        let app = UIApplication.sharedApplication()
        let url = NSURL(string: "https://m.facebook.com/events/\(self.eventId)")
        app.openURL(url!)
    }

// MARK: NSCoding
    required convenience init?(coder aDecoder: NSCoder) {
        let eventId = aDecoder.decodeObjectForKey(PropertyKey.eventIdKey) as! String
        self.init(eventId: eventId)

        self.valid = aDecoder.decodeObjectForKey(PropertyKey.validKey) as! Bool
        self.imageUrl = aDecoder.decodeObjectForKey(PropertyKey.smallImageUrlKey) as? NSURL

        self.attendees = aDecoder.decodeObjectForKey(PropertyKey.attendeesKey) as! UInt
        self.friendsAttending = aDecoder.decodeObjectForKey(PropertyKey.friendsAttendingKey) as? [FacebookEventFriend]
        self.userRsvp = FacebookEventRsvp(rawValue: aDecoder.decodeObjectForKey(PropertyKey.userRsvpKey) as! Int)!

        self.lastUpdated = aDecoder.decodeObjectForKey(PropertyKey.lastUpdatedKey) as? NSDate
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(valid, forKey: PropertyKey.validKey)
        aCoder.encodeObject(imageUrl, forKey: PropertyKey.smallImageUrlKey)

        aCoder.encodeObject(attendees, forKey: PropertyKey.attendeesKey)
        aCoder.encodeObject(friendsAttending, forKey: PropertyKey.friendsAttendingKey)
        aCoder.encodeObject(userRsvp.hashValue, forKey: PropertyKey.userRsvpKey)

        aCoder.encodeObject(lastUpdated, forKey: PropertyKey.lastUpdatedKey)
        aCoder.encodeObject(eventId, forKey: PropertyKey.eventIdKey)
    }

    // MARK: Fill-in event
    func facebookSessionStateChanged(notification: NSNotification) {
        let session = FacebookSession.sharedSession
        if !session.open {
            userRsvp = .None
            friendsAttending = nil
        }

        // Force update on next access
        self.lastUpdated = nil
    }

    func update() {
        if let lastUpdated = self.lastUpdated where lastUpdated.minutesBeforeDate(NSDate()) < 60 {
            return
        }

        self.fetchEventInfo()
        self.fetchUserInfo()
        //self.fetchFriendsInfo() //TODO: do fetch friends info

        self.lastUpdated = NSDate()
    }

    func fetchEventInfo() {
        print("Fetching information on event '\(self.eventId)'")

        let query = "/'\(self.eventId)'"

        FacebookSession.sharedSession.requestWithGraphPath(query, parameters: ["fields": "attending_count,cover"]) { (result) -> Void in
            if let data = result.valueForKey("data") as? NSArray, let dict: NSDictionary? = data[0] as? NSDictionary where data.count > 0 {
                if let attending_count = dict?.valueForKey("attending_count") as? UInt {
                    self.attendees = attending_count
                }
                if let cover = dict?.valueForKey("cover") as? NSDictionary, let pic = cover.valueForKey("source") as? String {
                    self.imageUrl = NSURL(string: pic)
                }
                NSNotificationCenter.defaultCenter().postNotificationName(FacebookEventDidUpdateNotification, object: nil)

                self.valid = true
            }
        }
    }

    func fetchUserInfo() {
        /*print("Fetching user information on event \(self.eventId)")

        let query = "SELECT rsvp_status FROM event_member WHERE eid = '\(self.eventId)' AND uid = me()"

        FacebookSession.sharedSession.requestWithQuery(query) { (result) -> Void in
            if let data = result.valueForKey("data") as? NSArray where data.count > 0 {
                if let dict = data[0] as? NSDictionary {
                    if let rsvp_status = dict.valueForKey("rsvp_status") as? String {
                        switch (rsvp_status) {
                        case "attending":
                            self.userRsvp = .Attending
                            break
                        case "unsure":
                            self.userRsvp = .Unsure
                            break
                        case "declined":
                            self.userRsvp = .Declined
                            break
                        default:
                            self.userRsvp = .None
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName(FacebookEventDidUpdateNotification, object: nil)
                    }
                    else {
                        self.userRsvp = .None
                        print("No dictionary")
                    }
                }
            }
        }*/
    }

    func fetchFriendsInfo() {
        // TODO: find some other way to get this info
        /* print("Fetching users friends information on event \(self.eventId)")

        let query = "SELECT name, pic_square FROM user WHERE uid IN " +
                    "(SELECT uid2 FROM friend WHERE uid1 = me() AND uid2 IN " +
                    "(SELECT uid FROM event_member WHERE eid = '\(self.eventId)' AND " +
                    "rsvp_status = 'attending'))"

        print(query)

        FacebookSession.sharedSession.requestWithQuery(query) { (result) -> Void in
            if let data = result.valueForKey("data") as? NSArray {
                print(data)
            }
        }*/
    }

    func updateUserRsvp(userRsvp: FacebookEventRsvp) {
        if self.userRsvp == userRsvp {
            return
        }

        // Check if logged in
        let session = FacebookSession.sharedSession
        self.userRsvpUpdating = true
        if !session.open {
            session.openWithAllowLoginUI(true, completion: { () -> Void in
                self.updateUserRsvp(userRsvp)
            })
        // Check if permission are granted
        } else if FBSDKAccessToken.currentAccessToken().hasGranted("rsvp_event") {
            let state = userRsvp.graphRequestString()
            let request = FBSDKGraphRequest(graphPath: "\(self.eventId)/\(state)", parameters: nil)

            request.startWithCompletionHandler({ (connection, response, error) -> Void in
                if let error = error {
                    self.userRsvpUpdating = false
                    // Handle error
                    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    delegate.handleError(error)
                } else {
                    self.userRsvp = userRsvp

                    let center = NSNotificationCenter.defaultCenter()
                    center.postNotificationName(FacebookSessionStateChangedNotification, object: nil)
                }
            })

        } else {
            // Request permissions
            let loginManager = FBSDKLoginManager()
            print("Requesting publish permission 'rsvp_event' for \(self.eventId)")
            loginManager.logInWithPublishPermissions(["rsvp_event"], handler: { (result, error) -> Void in
                if let error = error {
                    self.userRsvpUpdating = false
                    // Handle error
                    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    delegate.handleError(error)
                } else {
                    self.updateUserRsvp(userRsvp)
                }
            })
        }

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
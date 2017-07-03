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
    case none, attending, unsure, declined
    func localizedString() -> String {
        switch(self) {
        case .none:
            return ""
        case .attending:
            return "aanwezig"
        case .unsure:
            return "misschien"
        case .declined:
            return "niet aanwezig"
        }
    }

    func graphRequestString() -> String? {
        switch(self) {
        case .attending:
            return "attending"
        case .unsure:
            return "unsure"
        case .declined:
            return "declined"
        case .none:
            return nil
        }
    }
}

class FacebookEvent: NSObject, NSCoding {
    var valid: Bool = false
    var imageUrl: URL?

    var attendees: UInt = 0
    var friendsAttending: [FacebookEventFriend]?
    var userRsvp: FacebookEventRsvp = .none
    var userRsvpUpdating = false

    fileprivate var eventId: String
    fileprivate var lastUpdated: Date?

    init(eventId: String) {
        self.eventId = eventId

        super.init()

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(FacebookEvent.facebookSessionStateChanged(_:)), name: NSNotification.Name(rawValue: FacebookSessionStateChangedNotification), object: nil)

        self.update()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func showExternally() {
        let app = UIApplication.shared
        let url = URL(string: "https://m.facebook.com/events/\(self.eventId)")
        app.openURL(url!)
    }

// MARK: NSCoding
    required convenience init?(coder aDecoder: NSCoder) {
        let eventId = aDecoder.decodeObject(forKey: PropertyKey.eventIdKey) as! String
        self.init(eventId: eventId)

        self.valid = aDecoder.decodeBool(forKey: PropertyKey.validKey)
        self.imageUrl = aDecoder.decodeObject(forKey: PropertyKey.smallImageUrlKey) as? URL

        self.attendees = aDecoder.decodeObject(forKey: PropertyKey.attendeesKey) as! UInt
        self.friendsAttending = aDecoder.decodeObject(forKey: PropertyKey.friendsAttendingKey) as? [FacebookEventFriend]
        self.userRsvp = FacebookEventRsvp(rawValue: aDecoder.decodeInteger(forKey: PropertyKey.userRsvpKey))!

        self.lastUpdated = aDecoder.decodeObject(forKey: PropertyKey.lastUpdatedKey) as? Date
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(valid, forKey: PropertyKey.validKey)
        aCoder.encode(imageUrl, forKey: PropertyKey.smallImageUrlKey)

        aCoder.encode(attendees, forKey: PropertyKey.attendeesKey)
        aCoder.encode(friendsAttending, forKey: PropertyKey.friendsAttendingKey)
        aCoder.encode(userRsvp.hashValue, forKey: PropertyKey.userRsvpKey)

        aCoder.encode(lastUpdated, forKey: PropertyKey.lastUpdatedKey)
        aCoder.encode(eventId, forKey: PropertyKey.eventIdKey)
    }

    // MARK: Fill-in event
    @objc func facebookSessionStateChanged(_ notification: Notification) {
        let session = FacebookSession.sharedSession
        if !session.open {
            userRsvp = .none
            friendsAttending = nil
        }

        // Force update on next access
        self.lastUpdated = nil
    }

    func update() {
        if let lastUpdated = self.lastUpdated, (lastUpdated as NSDate).minutes(before: Date()) < 60 {
            return
        }

        self.fetchEventInfo()
        self.fetchUserInfo()
        //self.fetchFriendsInfo() //TODO: do fetch friends info

        self.lastUpdated = Date()
    }

    func fetchEventInfo() {
        print("Fetching information on event '\(self.eventId)'")

        let query = "/'\(self.eventId)'"

        FacebookSession.sharedSession.requestWithGraphPath(query, parameters: ["fields": "attending_count,cover"]) { (result) -> Void in
            if let data = result.value(forKey: "data") as? NSArray, let dict: NSDictionary? = data[0] as? NSDictionary, data.count > 0 {
                if let attending_count = dict?.value(forKey: "attending_count") as? UInt {
                    self.attendees = attending_count
                }
                if let cover = dict?.value(forKey: "cover") as? NSDictionary, let pic = cover.value(forKey: "source") as? String {
                    self.imageUrl = URL(string: pic)
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: FacebookEventDidUpdateNotification), object: nil)

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

    func updateUserRsvp(_ userRsvp: FacebookEventRsvp) {
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
        } else if FBSDKAccessToken.current().hasGranted("rsvp_event") {
            let state = userRsvp.graphRequestString()
            let request = FBSDKGraphRequest(graphPath: "\(self.eventId)/\(state)", parameters: nil)

            request?.start(completionHandler: { (connection, response, error) -> Void in
                if let error = error {
                    self.userRsvpUpdating = false
                    // Handle error
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.handleError(error: error)
                } else {
                    self.userRsvp = userRsvp

                    let center = NotificationCenter.default
                    center.post(name: Notification.Name(rawValue: FacebookSessionStateChangedNotification), object: nil)
                }
            })

        } else {
            // Request permissions
            let loginManager = FBSDKLoginManager()
            print("Requesting publish permission 'rsvp_event' for \(self.eventId)")
            loginManager.logIn(withPublishPermissions: ["rsvp_event"], handler: { (result, error) -> Void in
                if let error = error {
                    self.userRsvpUpdating = false
                    // Handle error
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.handleError(error: error)
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
    var photoUrl: URL?

    init(name: String, photoUrl: URL?) {
        self.name = name
        self.photoUrl = photoUrl
    }

    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        self.photoUrl = aDecoder.decodeObject(forKey: PropertyKey.photoUrlKey) as? URL
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(photoUrl, forKey: PropertyKey.photoUrlKey)
    }

    struct PropertyKey {
        static let nameKey = "name"
        static let photoUrlKey = "photoUrl"
    }
}

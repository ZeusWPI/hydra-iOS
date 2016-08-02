//
//  MinervaStore.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 26/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

let MinervaStoreDidUpdateCoursesNotification = "MinervaStoreDidUpdateCourses"
let MinervaStoreDidUpdateCourseInfoNotification = "MinervaStoreDidUpdateCourseInfo"
let MinervaStoreDidUpdateUserNotification = "MinervaStoreDidUpdateUser"

class MinervaStore: SavableStore, NSCoding {

    private static var _SharedStore: MinervaStore?
    static var sharedStore: MinervaStore {
        get {
            //TODO: make lazy, and catch NSKeyedUnarchiver errors
            if let _SharedStore = _SharedStore {
                return _SharedStore
            } else  {
                let minervaStore = NSKeyedUnarchiver.unarchiveObjectWithFile(Config.MinervaStoreArchive.path!) as? MinervaStore
                if let minervaStore = minervaStore {
                    _SharedStore = minervaStore
                    return _SharedStore!
                }
            }
            // initialize new one
            _SharedStore = MinervaStore()
            return _SharedStore!
        }
    }

    init() {
        super.init(storagePath: Config.MinervaStoreArchive.path!)
    }

    private var coursesLastUpdated = NSDate(timeIntervalSince1970: 0)
    private var _courses: [Course] = []
    var courses: [Course] {
        get {
            self.updateCourses()
            return _courses
        }
    }

    private var userLastUpdated = NSDate(timeIntervalSince1970: 0)
    private var _user: User? = nil
    var user: User? {
        get {
            if let user = self._user {
                return user
            }

            self.updateUser()
            return nil
        }
    }
    private var userRequestInProgress = false

    private var courseLastUpdated: [String: NSDate] = [:]
    private var _announcements: [String: [Announcement]] = [:]

    func announcement(course: Course, forcedUpdate: Bool = false) -> [Announcement]? {
        if let announcements = _announcements[course.internalIdentifier!] {
            return announcements
        }
        updateAnnouncements(course, forcedUpdate: forcedUpdate)

        return nil
    }

    private var _calendarItems: [String: [CalendarItem]] = [:]

    func calendarItem(course: Course, forcedUpdate: Bool = false) -> [CalendarItem]? {
        if let calendarItems = _calendarItems[course.internalIdentifier!] {
            return calendarItems
        }
        updateCalendarItems(course, forcedUpdate: forcedUpdate)

        return nil
    }

    func updateCourses(forcedUpdate: Bool = false) {
        let url = APIConfig.Minerva + "courses"

        self.updateResource(url, notificationName: MinervaStoreDidUpdateCoursesNotification, lastUpdated: coursesLastUpdated, forceUpdate: forcedUpdate, keyPath: "courses", oauth: true) { (courses: [Course]) in
            self._courses = courses
            self.coursesLastUpdated = NSDate()
        }
    }

    func updateUser(forcedUpdate: Bool = false) {
        let url = APIConfig.OAuth + "tokeninfo"

        if userRequestInProgress {
            return
        }

        if userLastUpdated.dateBySubtractingDays(10).isLaterThanDate(NSDate()) {
            return
        }

        userRequestInProgress = true
        UGentOAuth2Service.sharedService.oauth2.request(.GET, url)
            .responseObject { (response: Response<OAuthTokenInfo, NSError>) in
                if response.result.isFailure {
                    print("Tokeninfo request failed!")
                    return
                }

                guard let tokenInfo = response.result.value else {
                    print("No response data")
                    return
                }
                
                self._user = tokenInfo.user

                self.userRequestInProgress = false
                self.userLastUpdated = NSDate()

                if self._user != nil {
                    NSNotificationCenter.defaultCenter().postNotificationName(MinervaStoreDidUpdateUserNotification, object: self)
                }
        }
    }

    func updateAnnouncements(course: Course, forcedUpdate: Bool = false) {
        self.updateWhatsnew(course, forcedUpdate: forcedUpdate)
    }

    func updateCalendarItems(course: Course, forcedUpdate: Bool = false) {
        self.updateWhatsnew(course, forcedUpdate: forcedUpdate)
    }

    func updateWhatsnew(course: Course, forcedUpdate: Bool = false) {
        let url = APIConfig.Minerva + "course/\(course.internalIdentifier!)/whatsnew"

        var lastUpdated = self.courseLastUpdated[course.internalIdentifier!]

        if lastUpdated == nil {
            lastUpdated = NSDate(timeIntervalSince1970: 0)
        }

        self.updateResourceObject(url, notificationName: MinervaStoreDidUpdateCourseInfoNotification, lastUpdated: lastUpdated!, forceUpdate: forcedUpdate, oauth: true) { (whatsNew: WhatsNew) in
            print(whatsNew)
            self._announcements[course.internalIdentifier!] = whatsNew.announcement
            self._calendarItems[course.internalIdentifier!] = whatsNew.agenda
            self.courseLastUpdated[course.internalIdentifier!] = NSDate()
        }
    }

    func logoff() {
        self._courses = []
        self.coursesLastUpdated = NSDate(timeIntervalSince1970: 0)
        self._announcements = [String : [Announcement]]()
        self.courseLastUpdated = [String: NSDate]()
        self._calendarItems = [String: [CalendarItem]]()
        self._user = nil
        self.userLastUpdated = NSDate(timeIntervalSince1970: 0)

        PreferencesService.sharedService.unselectedMinervaCourses = Set<String>()
        self.saveLater()
    }

    // MARK: Conform to NSCoding
    required init?(coder aDecoder: NSCoder) {
        super.init(storagePath: Config.MinervaStoreArchive.path!)
        self._courses = aDecoder.decodeObjectForKey(PropertyKey.coursesKey) as! [Course]
        self.coursesLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.coursesLastUpdatedKey) as! NSDate
        self._announcements = aDecoder.decodeObjectForKey(PropertyKey.announcementsKey) as! [String: [Announcement]]
        self.courseLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.courseLastUpdatedKey) as! [String: NSDate]
        self._calendarItems = aDecoder.decodeObjectForKey(PropertyKey.calendarItemsKey) as! [String: [CalendarItem]]
        self._user = aDecoder.decodeObjectForKey(PropertyKey.userKey) as? User
        self.userLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.userLastUpdatedKey) as! NSDate
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self._courses, forKey: PropertyKey.coursesKey)
        aCoder.encodeObject(self.coursesLastUpdated, forKey: PropertyKey.coursesLastUpdatedKey)
        aCoder.encodeObject(self._announcements, forKey: PropertyKey.announcementsKey)
        aCoder.encodeObject(self.courseLastUpdated, forKey: PropertyKey.courseLastUpdatedKey)
        aCoder.encodeObject(self._calendarItems, forKey: PropertyKey.calendarItemsKey)
        aCoder.encodeObject(self.user, forKey: PropertyKey.userKey)
        aCoder.encodeObject(self.userLastUpdated, forKey: PropertyKey.userLastUpdatedKey)
    }

    struct PropertyKey {
        static let coursesKey = "courses"
        static let coursesLastUpdatedKey = "coursesLastUpdated"
        static let announcementsKey = "announcements"
        static let courseLastUpdatedKey = "courseLastUpdated"
        static let calendarItemsKey = "calendarItems"
        static let userKey = "user"
        static let userLastUpdatedKey = "userLastUpdatedKey"
    }
}
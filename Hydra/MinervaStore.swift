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
let MinervaStoreDidUpdateCalendarNotification = "MinervaStoreDidUpdateCalendar"
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
    private var coursesDict = [String: Course]()
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

    private var _calendarItems =  [CalendarItem]()
    private var calendarItemsLastUpdated = NSDate(timeIntervalSince1970: 0)
    var calendarItems: [CalendarItem] {
        get {
            self.updateCalendarItems()
            return _calendarItems
        }
    }

    private var courseLastUpdated: [String: NSDate] = [:]
    private var _announcements: [String: [Announcement]] = [:]

    func announcement(course: Course, forcedUpdate: Bool = false) -> [Announcement]? {
        updateAnnouncements(course, forcedUpdate: forcedUpdate)
        if let announcements = _announcements[course.internalIdentifier!] {
            return announcements
        }

        return nil
    }

    func update() {
        //TODO: fill in
        guard UGentOAuth2Service.sharedService.isLoggedIn() else {
            return
        }

        updateCourses()
        updateUser()
        updateCalendarItems()
        for course in _courses {
            updateAnnouncements(course)
        }
    }

    // MARK: - Communication functions
    func updateCourses(forcedUpdate: Bool = false) {
        let url = APIConfig.Minerva + "courses"

        self.updateResource(url, notificationName: MinervaStoreDidUpdateCoursesNotification, lastUpdated: coursesLastUpdated, forceUpdate: forcedUpdate, keyPath: "courses", oauth: true) { (courses: [Course]) in
            self._courses = courses
            self.createCourseDict()
            if self._courses.count > 0 {
                self.coursesLastUpdated = NSDate()
            }
        }
    }

    func updateUser(forcedUpdate: Bool = false) {
        let url = APIConfig.OAuth + "tokeninfo"
        var forcedUpdate = forcedUpdate
        if _user == nil {
            forcedUpdate = true
        }
        self.updateResource(url, notificationName: MinervaStoreDidUpdateUserNotification, lastUpdated: self.userLastUpdated, forceUpdate: forcedUpdate, oauth: true) { (tokenInfo: OAuthTokenInfo) in
            self._user = tokenInfo.user
            if self._user != nil {
                self.userLastUpdated = NSDate()
            }
        }
    }

    func updateCalendarItems(forcedUpdate: Bool = false, start: NSDate? = nil, end: NSDate? = nil) {
        let url: String
        if let start = start, let end = end {
            url = APIConfig.Minerva + "agenda?start=\(start.timeIntervalSince1970)&end=\(end.timeIntervalSince1970)"
        } else {
            url = APIConfig.Minerva  + "agenda"
        }

        self.updateResource(url, notificationName: MinervaStoreDidUpdateCalendarNotification, lastUpdated: self.calendarItemsLastUpdated, forceUpdate: forcedUpdate, keyPath: "items", oauth: true) { (items: [CalendarItem]) in
            if items.count > 0 {
                self._calendarItems = items
                self.calendarItemsLastUpdated = NSDate()
            }
        }
    }

    func updateAnnouncements(course: Course, forcedUpdate: Bool = false) {
        let url = APIConfig.Minerva + "course/\(course.internalIdentifier!)/announcement"

        var lastUpdated = self.courseLastUpdated[course.internalIdentifier!]

        if lastUpdated == nil {
            lastUpdated = NSDate(timeIntervalSince1970: 0)
        }

        self.updateResource(url, notificationName: MinervaStoreDidUpdateCourseInfoNotification, lastUpdated: lastUpdated!, forceUpdate: forcedUpdate, keyPath: "items", oauth: true) { (items: [Announcement]) in
            print("\(course.title): \(items.count) announcements")
            var items = items
            let readAnnouncements: Set<Int>
            if let oldAnnouncements = self._announcements[course.internalIdentifier!] {
                readAnnouncements = Set<Int>(oldAnnouncements.filter{ $0.read }.map({ $0.itemId }))
            } else {
                readAnnouncements = Set<Int>()
            }

            for announcement in items {
                if readAnnouncements.contains(announcement.itemId) {
                    announcement.read = true
                }
            }

            items.sortInPlace { $0.date > $1.date }

            self._announcements[course.internalIdentifier!] = items
            if self._announcements[course.internalIdentifier!] != nil &&
                self._announcements[course.internalIdentifier!]?.count > 0  {
                self.courseLastUpdated[course.internalIdentifier!] = NSDate()
            }
        }
    }

    func logoff() {
        self._courses = []
        self.coursesLastUpdated = NSDate(timeIntervalSince1970: 0)
        self._announcements = [String : [Announcement]]()
        self.courseLastUpdated = [String: NSDate]()
        self._calendarItems = []
        self._user = nil
        self.userLastUpdated = NSDate(timeIntervalSince1970: 0)
        self.coursesDict = [:]
        NSNotificationCenter.defaultCenter().postNotificationName(MinervaStoreDidUpdateCoursesNotification, object: nil)

        PreferencesService.sharedService.unselectedMinervaCourses = Set<String>()
        self.syncStorage()
    }

    func course(identifier: String) -> Course? {
        return coursesDict[identifier]
    }

    func createCourseDict() {
        var courseDict = [String: Course]()
        for course in _courses {
            courseDict[course.internalIdentifier!] = course
        }
        self.coursesDict = courseDict
    }

    // MARK: Conform to NSCoding
    required init?(coder aDecoder: NSCoder) {
        super.init(storagePath: Config.MinervaStoreArchive.path!)
        self._courses = aDecoder.decodeObjectForKey(PropertyKey.coursesKey) as! [Course]
        self.coursesLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.coursesLastUpdatedKey) as! NSDate
        self._announcements = aDecoder.decodeObjectForKey(PropertyKey.announcementsKey) as! [String: [Announcement]]
        self.courseLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.courseLastUpdatedKey) as! [String: NSDate]
        guard let calendarItems = aDecoder.decodeObjectForKey(PropertyKey.calendarItemsKey) as? [CalendarItem] else {
            return nil
        }
        self._calendarItems = calendarItems
        self._user = aDecoder.decodeObjectForKey(PropertyKey.userKey) as? User
        self.userLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.userLastUpdatedKey) as! NSDate

        createCourseDict()

        if !PreferencesService.sharedService.userLoggedInToMinerva {
            self.logoff()
        }
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

    func sortedByDate() -> [NSDate: [CalendarItem]] {
        // TODO: write somewhat better algorithm
        var sorted = [NSDate: [CalendarItem]]()

        let hiddenCourses = PreferencesService.sharedService.unselectedMinervaCourses

        for calendarItem in _calendarItems {
            if hiddenCourses.contains(calendarItem.courseId) {
                break
            }
            let date = calendarItem.startDate.dateAtStartOfDay()
            let endDate = calendarItem.endDate.dateAtStartOfDay()

            var dateItems = sorted[date]
            if dateItems == nil {
                dateItems = []
            }
            dateItems?.append(calendarItem)
            sorted[date] = dateItems

            //TODO: maybe in while loop
            if date != endDate {
                // ends in different day
                var dateItems = sorted[endDate]
                if dateItems == nil {
                    dateItems = []
                }
                dateItems?.append(calendarItem)
                sorted[endDate] = dateItems
            }
        }
        return sorted
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

extension MinervaStore: FeedItemProtocol {

    func feedItems() -> [FeedItem] {
        guard UGentOAuth2Service.sharedService.isLoggedIn() else {
            return [FeedItem(itemType: .MinervaSettingsItem, object: nil, priority: 900)]
        }

        var feedItems = [FeedItem]()
        let hiddenCourses = PreferencesService.sharedService.unselectedMinervaCourses

        let oneWeekLater = NSDate(daysFromNow: 7)
        let now = NSDate()
        for course in _courses.filter({ !hiddenCourses.contains($0.internalIdentifier!) }) {
            let announcements = _announcements[course.internalIdentifier!]
            if let announcements = announcements {
                for announcement in announcements {
                    let date = announcement.date
                    let hoursBetween = date.hoursBeforeDate(now)
                    let priority = 950 - hoursBetween * 10

                    if priority < 0 {
                        continue
                    }
                    announcement.course = course
                    feedItems.append(FeedItem(itemType: .MinervaAnnouncementItem, object: announcement, priority: priority))
                }
            }
        }

        for calendarItem in _calendarItems.filter({
            if let course = $0.course, let internalIdentifier = course.internalIdentifier {
                 return !hiddenCourses.contains(internalIdentifier)
            }
            return false
        }) {
            let endDate = calendarItem.endDate
            let startDate = calendarItem.startDate
            if endDate.isEarlierThanDate(now) || startDate.isLaterThanDate(oneWeekLater) {
                continue
            }
            let hoursBetween = startDate.hoursAfterDate(now)
            let priority: Int

            if hoursBetween < 2 {
                priority = 1000
            } else {
                priority = 950 - hoursBetween * 10
            }
            feedItems.append(FeedItem(itemType: .MinervaCalendarItem, object: calendarItem, priority: priority))
        }
        return feedItems
    }
}
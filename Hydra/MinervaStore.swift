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
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

let MinervaStoreDidUpdateCoursesNotification = "MinervaStoreDidUpdateCourses"
let MinervaStoreDidUpdateCalendarNotification = "MinervaStoreDidUpdateCalendar"
let MinervaStoreDidUpdateCourseInfoNotification = "MinervaStoreDidUpdateCourseInfo"
let MinervaStoreDidUpdateUserNotification = "MinervaStoreDidUpdateUser"

class MinervaStore: SavableStore, NSCoding {

    fileprivate static var _SharedStore: MinervaStore?
    static var sharedStore: MinervaStore {
        get {
            //TODO: make lazy, and catch NSKeyedUnarchiver errors
            if let _SharedStore = _SharedStore {
                return _SharedStore
            } else {
                let minervaStore = NSKeyedUnarchiver.unarchiveObject(withFile: Config.MinervaStoreArchive.path) as? MinervaStore
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
        super.init(storagePath: Config.MinervaStoreArchive.path)
    }

    fileprivate var coursesLastUpdated = Date(timeIntervalSince1970: 0)
    fileprivate var coursesDict = [String: Course]()
    fileprivate var _courses: [Course] = []
    var courses: [Course] {
        get {
            self.updateCourses()
            return _courses
        }
    }

    var filteredCourses: [Course] {
        get {
            let hiddenCourses = PreferencesService.sharedService.unselectedMinervaCourses

            self.updateCourses()
            return _courses.filter({ !hiddenCourses.contains($0.internalIdentifier!) })
        }
    }

    fileprivate var userLastUpdated = Date(timeIntervalSince1970: 0)
    fileprivate var _user: User? = nil
    var user: User? {
        get {
            if let user = self._user {
                return user
            }

            self.updateUser()
            return nil
        }
    }

    fileprivate var _calendarItems =  [CalendarItem]()
    fileprivate var calendarItemsLastUpdated = Date(timeIntervalSince1970: 0)
    var calendarItems: [CalendarItem] {
        get {
            self.updateCalendarItems()
            return _calendarItems
        }
    }

    fileprivate var courseLastUpdated: [String: Date] = [:]
    fileprivate var _announcements: [String: [Announcement]] = [:]

    func announcement(_ course: Course, forcedUpdate: Bool = false) -> [Announcement]? {
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
    func updateCourses(_ forcedUpdate: Bool = false) {
        let url = APIConfig.Minerva + "courses"

        self.updateResource(url, notificationName: MinervaStoreDidUpdateCoursesNotification, lastUpdated: coursesLastUpdated, forceUpdate: forcedUpdate, keyPath: "courses", oauth: true) { (courses: [Course]) in
            self._courses = courses
            self.createCourseDict()
            if self._courses.count > 0 {
                self.coursesLastUpdated = Date()
            }
        }
    }

    func updateUser(_ forcedUpdate: Bool = false) {
        let url = APIConfig.OAuth + "tokeninfo"
        var forcedUpdate = forcedUpdate
        if _user == nil {
            forcedUpdate = true
        }
        self.updateResource(url, notificationName: MinervaStoreDidUpdateUserNotification, lastUpdated: self.userLastUpdated, forceUpdate: forcedUpdate, oauth: true) { (tokenInfo: OAuthTokenInfo) in
            self._user = tokenInfo.user
            if self._user != nil {
                self.userLastUpdated = Date()
            }
        }
    }

    func updateCalendarItems(_ forcedUpdate: Bool = false, start: Date? = nil, end: Date? = nil) {
        let url: String
        if let start = start, let end = end {
            url = APIConfig.Minerva + "agenda?start=\(start.timeIntervalSince1970)&end=\(end.timeIntervalSince1970)"
        } else {
            url = APIConfig.Minerva  + "agenda"
        }

        self.updateResource(url, notificationName: MinervaStoreDidUpdateCalendarNotification, lastUpdated: self.calendarItemsLastUpdated, forceUpdate: forcedUpdate, keyPath: "items", oauth: true) { (items: [CalendarItem]) in
            if items.count > 0 {
                self._calendarItems = items
                self.calendarItemsLastUpdated = Date()
            }
        }
    }

    func updateAnnouncements(_ course: Course, forcedUpdate: Bool = false) {
        let url = APIConfig.Minerva + "course/\(course.internalIdentifier!)/announcement"

        var lastUpdated = self.courseLastUpdated[course.internalIdentifier!]

        if lastUpdated == nil {
            lastUpdated = Date(timeIntervalSince1970: 0)
        }

        self.updateResource(url, notificationName: MinervaStoreDidUpdateCourseInfoNotification, lastUpdated: lastUpdated!, forceUpdate: forcedUpdate, keyPath: "items", oauth: true) { (items: [Announcement]) in
            print("\(course.title): \(items.count) announcements")
            var items = items
            let readAnnouncements: Set<Int>
            if let oldAnnouncements = self._announcements[course.internalIdentifier!] {
                readAnnouncements = Set<Int>(oldAnnouncements.filter { $0.read }.map({ $0.itemId }))
            } else {
                readAnnouncements = Set<Int>()
            }

            for announcement in items {
                if readAnnouncements.contains(announcement.itemId) {
                    announcement.read = true
                }
            }

            items.sort { $0.date > $1.date }

            self._announcements[course.internalIdentifier!] = items
            if self._announcements[course.internalIdentifier!] != nil &&
                self._announcements[course.internalIdentifier!]?.count > 0 {
                self.courseLastUpdated[course.internalIdentifier!] = Date()
            }
        }
    }

    func logoff() {
        self._courses = []
        self.coursesLastUpdated = Date(timeIntervalSince1970: 0)
        self._announcements = [String : [Announcement]]()
        self.courseLastUpdated = [String: Date]()
        self._calendarItems = []
        self._user = nil
        self.userLastUpdated = Date(timeIntervalSince1970: 0)
        self.coursesDict = [:]
        NotificationCenter.default.post(name: Notification.Name(rawValue: MinervaStoreDidUpdateCoursesNotification), object: nil)

        PreferencesService.sharedService.unselectedMinervaCourses = Set<String>()
        self.syncStorage()
    }

    func course(_ identifier: String) -> Course? {
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
        super.init(storagePath: Config.MinervaStoreArchive.path)
        guard let courses = aDecoder.decodeObject(forKey: PropertyKey.coursesKey) as? [Course],
            let coursesLastUpdated = aDecoder.decodeObject(forKey: PropertyKey.coursesLastUpdatedKey) as? Date,
            let announcements = aDecoder.decodeObject(forKey: PropertyKey.announcementsKey) as? [String: [Announcement]],
            let courseLastUpdated = aDecoder.decodeObject(forKey: PropertyKey.courseLastUpdatedKey) as? [String: Date],
            let calendarItems = aDecoder.decodeObject(forKey: PropertyKey.calendarItemsKey) as? [CalendarItem] else {
            return nil
        }
        self._courses = courses
        self.coursesLastUpdated = coursesLastUpdated
        self._announcements = announcements
        self.courseLastUpdated = courseLastUpdated
        self._calendarItems = calendarItems

        self._user = aDecoder.decodeObject(forKey: PropertyKey.userKey) as? User
        self.userLastUpdated = aDecoder.decodeObject(forKey: PropertyKey.userLastUpdatedKey) as! Date

        createCourseDict()

        if !PreferencesService.sharedService.userLoggedInToMinerva {
            self.logoff()
        }
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self._courses, forKey: PropertyKey.coursesKey)
        aCoder.encode(self.coursesLastUpdated, forKey: PropertyKey.coursesLastUpdatedKey)
        aCoder.encode(self._announcements, forKey: PropertyKey.announcementsKey)
        aCoder.encode(self.courseLastUpdated, forKey: PropertyKey.courseLastUpdatedKey)
        aCoder.encode(self._calendarItems, forKey: PropertyKey.calendarItemsKey)
        aCoder.encode(self.user, forKey: PropertyKey.userKey)
        aCoder.encode(self.userLastUpdated, forKey: PropertyKey.userLastUpdatedKey)
    }

    func sortedByDate() -> [Date: [CalendarItem]] {
        // TODO: write somewhat better algorithm
        var sorted = [Date: [CalendarItem]]()

        let hiddenCourses = PreferencesService.sharedService.unselectedMinervaCourses

        for calendarItem in calendarItems {
            if hiddenCourses.contains(calendarItem.courseId) {
                break
            }
            let date = (calendarItem.startDate as NSDate).atStartOfDay()
            let endDate = (calendarItem.endDate as NSDate).atStartOfDay()

            var dateItems = sorted[date!]
            if dateItems == nil {
                dateItems = []
            }
            dateItems?.append(calendarItem)
            sorted[date!] = dateItems

            //TODO: maybe in while loop
            if date != endDate {
                // ends in different day
                var dateItems = sorted[endDate!]
                if dateItems == nil {
                    dateItems = []
                }
                dateItems?.append(calendarItem)
                sorted[endDate!] = dateItems
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
            return [FeedItem(itemType: .minervaSettingsItem, object: nil, priority: 900)]
        }

        var feedItems = [FeedItem]()
        let hiddenCourses = PreferencesService.sharedService.unselectedMinervaCourses

        let oneWeekLater = NSDate(daysFromNow: 7)
        let now = Date()
        for course in _courses.filter({ !hiddenCourses.contains($0.internalIdentifier!) }) {
            let announcements = _announcements[course.internalIdentifier!]
            if let announcements = announcements {
                for announcement in announcements {
                    let date = announcement.date
                    let hoursBetween = (date as NSDate).hours(before: now)
                    let priority = 950 - hoursBetween * 10

                    if priority < 0 {
                        continue
                    }
                    announcement.course = course
                    feedItems.append(FeedItem(itemType: .minervaAnnouncementItem, object: announcement, priority: priority))
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
            if (endDate as NSDate).isEarlierThanDate(now) || (startDate as NSDate).isLaterThanDate(oneWeekLater as Date!) {
                continue
            }
            let hoursBetween = (startDate as NSDate).hours(after: now)
            let priority: Int

            if hoursBetween < 2 {
                priority = 1000
            } else {
                priority = 950 - hoursBetween * 10
            }
            feedItems.append(FeedItem(itemType: .minervaCalendarItem, object: calendarItem, priority: priority))
        }
        return feedItems
    }
}

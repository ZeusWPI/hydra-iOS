//
//  MinervaStore.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 26/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import Alamofire

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

class MinervaStore: SavableStore, Codable {

    fileprivate static var _shared: MinervaStore?
    static var shared: MinervaStore {
        get {
            if let shared = _shared {
                return shared
            }
            
            _shared = SavableStore.loadStore(self, from: Config.MinervaStoreArchive)
            return _shared!
        }
    }
    
    override func syncStorage() {
        super.syncStorage(obj: self, storageURL: Config.MinervaStoreArchive)
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

        self.updateResource(url, notificationName: MinervaStoreDidUpdateCoursesNotification, lastUpdated: coursesLastUpdated, forceUpdate: forcedUpdate,  oauth: true) { (courses: Courses) in
            self._courses = courses.courses
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

        self.updateResource(url, notificationName: MinervaStoreDidUpdateCalendarNotification, lastUpdated: self.calendarItemsLastUpdated, forceUpdate: forcedUpdate, oauth: true) { (items: CalendarItems) in
            if items.items.count > 0 {
                self._calendarItems = items.items
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

        self.updateResource(url, notificationName: MinervaStoreDidUpdateCourseInfoNotification, lastUpdated: lastUpdated!, forceUpdate: forcedUpdate,  oauth: true) { (items: Announcements) in
            print("\(String(describing: course.title)): \(items.items.count) announcements")
            var items = items.items
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
            if (endDate as NSDate).isEarlierThanDate(now) || (startDate as NSDate).isLaterThanDate(oneWeekLater! as Date) {
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

fileprivate struct Courses: Codable {
    let courses: [Course]
}

fileprivate struct CalendarItems: Codable {
    let items: [CalendarItem]
}

fileprivate struct Announcements: Codable {
    let items: [Announcement]
}

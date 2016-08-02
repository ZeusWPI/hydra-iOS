//
//  MinervaStore.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 26/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

let MinervaStoreDidUpdateCoursesNotification = "MinervaStoreDidUpdateCourses"

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

    private var announcementsLastUpdated: [String: NSDate] = [:]
    private var _announcements: [String: [Announcement]] = [:]

    func announcement(course: Course, forcedUpdate: Bool = false) -> [Announcement]? {
        if let announcements = _announcements[course.code!] {
            return announcements
        }

        return nil
    }

    private var calendarLastUpdated: [String: NSDate] = [:]
    private var _calendarItems: [String: [CalendarItem]] = [:]

    func updateCourses(forcedUpdate: Bool = false) {
        let url = APIConfig.Minerva + "courses"

        self.updateResource(url, notificationName: MinervaStoreDidUpdateCoursesNotification, lastUpdated: coursesLastUpdated, forceUpdate: forcedUpdate, keyPath: "courses", oauth: true) { (courses: [Course]) in
            self._courses = courses
            self.coursesLastUpdated = NSDate()
        }
    }

    func updateUser(forcedUpdate: Bool = false) {

    }

    func updateAnnouncements(course: Course, forcedUpdate: Bool = false) {

    }

    // MARK: Conform to NSCoding
    required init?(coder aDecoder: NSCoder) {
        super.init(storagePath: Config.MinervaStoreArchive.path!)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        
    }
}
//
//  PreferencesService.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 07/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class PreferencesService: NSObject {

    @objc static let sharedService = PreferencesService()

    let defaults = UserDefaults.standard

    static func registerAppDefaults() {
        let defaultProps = [PropertyKey.showActivitiesInFeedKey: true,
                            PropertyKey.showNewsInFeedKey: true,
                            PropertyKey.showUrgentfmInFeedKey: true,
                            PropertyKey.showSchamperInFeedKey: true,
                            PropertyKey.showSko: true,
                            PropertyKey.showRestoInFeedKey: true,
                            PropertyKey.showSpecialEventsInFeedKey: true,
                            PropertyKey.filterAssociationsKey: false,
                            PropertyKey.firstLaunchKey: true
        ]
        UserDefaults.standard.register(defaults: defaultProps)
    }

    var filterAssociations: Bool {
        get {
            // Default is false because we show the inverse
            return getBool(PropertyKey.filterAssociationsKey, defaultValue: false)
        }
        set {
            setBool(PropertyKey.filterAssociationsKey, value: newValue)
        }
    }

    var showActivitiesInFeed: Bool {
        get {
            return getBool(PropertyKey.showActivitiesInFeedKey, defaultValue: true)
        }
        set {
            setBool(PropertyKey.showActivitiesInFeedKey, value: newValue)
        }
    }

    var showSchamperInFeed: Bool {
        get {
            return getBool(PropertyKey.showSchamperInFeedKey, defaultValue: true)
        }
        set {
            setBool(PropertyKey.showSchamperInFeedKey, value: newValue)
        }
    }

    var showRestoInFeed: Bool {
        get {
            return getBool(PropertyKey.showRestoInFeedKey, defaultValue: true)
        }
        set {
            setBool(PropertyKey.showRestoInFeedKey, value: newValue)
        }
    }

    var showUrgentfmInFeed: Bool {
        get {
            return getBool(PropertyKey.showUrgentfmInFeedKey, defaultValue: true)
        }
        set {
            setBool(PropertyKey.showUrgentfmInFeedKey, value: newValue)
        }
    }

    var showNewsInFeed: Bool {
        get {
            return getBool(PropertyKey.showNewsInFeedKey, defaultValue: true)
        }
        set {
            setBool(PropertyKey.showNewsInFeedKey, value: newValue)
        }
    }

    var showSpecialEventsInFeed: Bool {
        get {
            return getBool(PropertyKey.showSpecialEventsInFeedKey, defaultValue: true)
        }
        set {
            setBool(PropertyKey.showSpecialEventsInFeedKey, value: newValue)
        }
    }

    var shownFacebookPrompt: Bool {
        get {
            return getBool(PropertyKey.shownFacebookPromptKey, defaultValue: true)
        }
        set {
            setBool(PropertyKey.shownFacebookPromptKey, value: newValue)
        }
    }

    var userLoggedInToFacebook: Bool {
        get {
            return getBool(PropertyKey.userLoggedInToFacebookKey, defaultValue: false)
        }
        set {
            setBool(PropertyKey.userLoggedInToFacebookKey, value: newValue)
        }
    }

    var userLoggedInToMinerva: Bool {
        get {
            return getBool(PropertyKey.userLoggedInToMinervaKey, defaultValue: false)
        }
        set {
            setBool(PropertyKey.userLoggedInToMinervaKey, value: newValue)
        }
    }

    var developmentMode: Bool {
        get {
            return getBool(PropertyKey.developmentModeKey, defaultValue: false)
        }
        set {
            setBool(PropertyKey.developmentModeKey, value: newValue)
        }
    }

    @objc var preferredAssociations: [String] { // Still in Obj-C
        get {
            return getArray(PropertyKey.preferredAssociationsKey, defaultValue: [String]() as NSArray) as! [String]
        }
        set {
            setArray(PropertyKey.preferredAssociationsKey, value: newValue as NSArray?)
        }
    }

    var hydraTabBarOrder: [Int] {
        get {
            return getArray(PropertyKey.hydraTabBarOrderKey, defaultValue: [Int]() as NSArray) as! [Int]
        }
        set {
            setArray(PropertyKey.hydraTabBarOrderKey, value: newValue as NSArray?)
        }
    }

    var unselectedMinervaCourses: Set<String> {
        get {
            let arr = getArray(PropertyKey.unselectedMinervaCoursesKey, defaultValue: [String]() as NSArray) as! [String]
            return Set<String>(arr)
        }
        set {
            setArray(PropertyKey.unselectedMinervaCoursesKey, value: Array<String>(newValue) as NSArray?)
        }
    }

    var notificationsEnabled: Bool {
        get {
            return getBool(PropertyKey.notificationsEnabledKey, defaultValue: false)
        }
        set {
            setBool(PropertyKey.notificationsEnabledKey, value: newValue)
        }

    }

    var lastAskedForNotifications: Date? {
        get {
            return getObject(PropertyKey.lastAskedForNoticationsKey) as? Date
        }
        set {
            setObject(PropertyKey.lastAskedForNoticationsKey, value: newValue as AnyObject?)
        }
    }

    var skoNotificationsEnabled: Bool {
        get {
            return getBool(PropertyKey.skoNotificationsEnabledKey, defaultValue: false)
        }
        set {
            setBool(PropertyKey.skoNotificationsEnabledKey, value: newValue)
        }
    }

    var skoNotificationsAsked: Bool {
        get {
            return getBool(PropertyKey.skoNotificationsAskedKey, defaultValue: false)
        }
        set {
            setBool(PropertyKey.skoNotificationsAskedKey, value: newValue)
        }
    }

    var showSKO: Bool {
        get {
            return getBool(PropertyKey.showSko, defaultValue: false)
        }
        set {
            setBool(PropertyKey.showSko, value: newValue)
        }
    }

    var firstLaunch: Bool {
        get {
            return getBool(PropertyKey.firstLaunchKey)
        }
        set {
            setBool(PropertyKey.firstLaunchKey, value: newValue)
        }
    }

    var resetApp: Bool {
        get {
            return getBool(PropertyKey.resetAppKey)
        }
        set {
            setBool(PropertyKey.resetAppKey, value: newValue)
        }
    }

    internal struct PropertyKey {
        static let filterAssociationsKey = "useAssociationFilter"
        static let preferredAssociationsKey = "preferredAssociations"
        static let showActivitiesInFeedKey = "showActivitiesInFeed"
        static let showSchamperInFeedKey = "showSchamperInFeed"
        static let showRestoInFeedKey = "showRestoInFeed"
        static let showUrgentfmInFeedKey = "showUrgentfmInFeed"
        static let showNewsInFeedKey = "showNewsInFeed"
        static let showSpecialEventsInFeedKey = "showSpecialEventsInFeed"
        static let developmentModeKey = "developmentMode"
        static let hydraTabBarOrderKey = "hydraTabBarOrder"
        static let shownFacebookPromptKey = "shownFacebookPrompt"
        static let userLoggedInToFacebookKey =  "userLoggedInToFacebook"
        static let userLoggedInToMinervaKey = "userLoggedInToMinerva"
        static let unselectedMinervaCoursesKey = "unselectedMinervaCourses"
        static let notificationsEnabledKey = "notficationsEnabled"
        static let lastAskedForNoticationsKey = "lastAskedForNotifications"
        static let skoNotificationsEnabledKey = "skoNotificationsEnabled"
        static let skoNotificationsAskedKey = "skoNotificationsAsked"
        static let showSko = "showSko"
        static let firstLaunchKey = "first_launch_preference"
        static let resetAppKey = "reset_app_preference"
    }

    // MARK: Utility methods
    fileprivate func getObject(_ key: String) -> AnyObject? {
        return self.defaults.object(forKey: key) as AnyObject?
    }

    fileprivate func getBool(_ key: String) -> Bool {
        return self.defaults.bool(forKey: key)
    }

    fileprivate func getArray(_ key: String) -> NSArray? {
        return self.defaults.array(forKey: key) as NSArray?
    }

    fileprivate func getObject(_ key: String, defaultValue: AnyObject) -> AnyObject? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getObject(key)
    }

    fileprivate func getBool(_ key: String, defaultValue: Bool) -> Bool {
        if getObject(key) == nil {
            return defaultValue
        }
        return getBool(key)
    }

    fileprivate func getArray(_ key: String, defaultValue: NSArray) -> NSArray {
        if getObject(key) == nil {
            return defaultValue
        }
        return getArray(key)!
    }

    fileprivate func setObject(_ key: String, value: AnyObject?) {
        if value == nil {
            self.defaults.removeObject(forKey: key)
        } else {
            self.defaults.set(value, forKey: key)
        }
        self.defaults.synchronize()
    }

    fileprivate func setBool(_ key: String, value: Bool) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    fileprivate func setArray(_ key: String, value: NSArray?) {
        setObject(key, value: value)
    }
}

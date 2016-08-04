//
//  PreferencesService.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 07/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class PreferencesService: NSObject {

    static let sharedService = PreferencesService()

    let defaults = NSUserDefaults.standardUserDefaults()


    var filterAssociations: Bool {
        get {
            return getBool(PropertyKey.filterAssociationsKey, defaultValue: true)
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

    var preferredAssociations: [String] { // Still in Obj-C
        get {
            return getArray(PropertyKey.preferredAssociationsKey, defaultValue: [String]()) as! [String]
        }
        set {
            setArray(PropertyKey.preferredAssociationsKey, value: newValue)
        }
    }

    var hydraTabBarOrder: [Int] {
        get {
            return getArray(PropertyKey.hydraTabBarOrderKey, defaultValue: [Int]()) as! [Int]
        }
        set {
            setArray(PropertyKey.hydraTabBarOrderKey, value: newValue)
        }
    }

    var unselectedMinervaCourses: Set<String> {
        get {
            let arr = getArray(PropertyKey.unselectedMinervaCoursesKey, defaultValue: [String]()) as! [String]
            return Set<String>(arr)
        }
        set {
            setArray(PropertyKey.unselectedMinervaCoursesKey, value: Array<String>(newValue))
        }
    }

    private struct PropertyKey {
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
    }

    // MARK: Utility methods
    private func getObject(key: String) -> AnyObject? {
        return self.defaults.objectForKey(key)
    }

    private func getBool(key: String) -> Bool {
        return self.defaults.boolForKey(key)
    }

    private func getArray(key: String) -> NSArray? {
        return self.defaults.arrayForKey(key)
    }

    private func getObject(key: String, defaultValue: AnyObject) -> AnyObject? {
        if getObject(key) == nil {
            return defaultValue
        }
        return getObject(key)
    }

    private func getBool(key: String, defaultValue: Bool) -> Bool {
        if getObject(key) == nil {
            return defaultValue
        }
        return getBool(key)
    }

    private func getArray(key: String, defaultValue: NSArray) -> NSArray {
        if getObject(key) == nil {
            return defaultValue
        }
        return getArray(key)!
    }

    private func setObject(key: String, value: AnyObject?) {
        if value == nil {
            self.defaults.removeObjectForKey(key)
        } else {
            self.defaults.setObject(value, forKey: key)
        }
        self.defaults.synchronize()
    }

    private func setBool(key: String, value: Bool) {
        defaults.setBool(value, forKey: key)
        defaults.synchronize()
    }

    private func setArray(key: String, value: NSArray?) {
        setObject(key, value: value)
    }
}
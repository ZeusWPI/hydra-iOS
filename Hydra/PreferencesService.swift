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
            return getBool(PropertyKey.userLoggedInToFacebookKey, defaultValue: true)
        }
        set {
            setBool(PropertyKey.userLoggedInToFacebookKey, value: newValue)
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

    struct PropertyKey {
        static let filterAssociationsKey = "useAssociationFilter"
        static let showActivitiesInFeedKey = "showActivitiesInFeed"
        static let preferredAssociationsKey = "preferredAssociations"
        static let hydraTabBarOrderKey = "hydraTabBarOrder"
        static let shownFacebookPromptKey = "shownFacebookPrompt"
        static let userLoggedInToFacebookKey =  "userLoggedInToFacebook"
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
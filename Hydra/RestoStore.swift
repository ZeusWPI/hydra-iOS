//
//  RestoStore.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 20/11/2015.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

let RestoStoreDidReceiveMenuNotification = "RestoStoreDidReceiveMenuNotification"
let RestoStoreDidUpdateInfoNotification = "RestoStoreDidUpdateInfoNotification"
let RestoStoreDidUpdateSandwichesNotification = "RestoStoreDidUpdateSandwichesNotification"

typealias RestoMenus = [NSDate: RestoMenu]

class RestoStore: SavableStore, NSCoding {

    private static var _SharedStore: RestoStore?
    static var sharedStore: RestoStore {
        get {
            if let _SharedStore = _SharedStore {
                return _SharedStore
            } else  {
                let restoStore = NSKeyedUnarchiver.unarchiveObjectWithFile(Config.RestoStoreArchive.path!) as? RestoStore
                if let restoStore = restoStore {
                    _SharedStore = restoStore
                    return _SharedStore!
                }
            }
            // initialize new one
            _SharedStore = RestoStore()
            return _SharedStore!
        }
    }


    private var _locations: [RestoLocation] = []
    var locations: [RestoLocation] {
        get {
            self.updateLocations()
            return self._locations
        }
    }
    private var _sandwiches: [RestoSandwich] = []
    var sandwiches: [RestoSandwich] {
        get {
            self.updateSandwiches()
            return self._sandwiches
        }
    }
    var menus: RestoMenus = [:]
    var selectedResto: String = "nl"

    var menusLastUpdated: NSDate?
    var locationsLastUpdated: NSDate?
    var sandwichesLastUpdated: NSDate?


    init() {
        super.init(storagePath: Config.RestoStoreArchive.path!)
    }

    required init?(coder aDecoder: NSCoder) {
        self._locations = aDecoder.decodeObjectForKey(PropertyKey.locationsKey) as! [RestoLocation]
        self._sandwiches = aDecoder.decodeObjectForKey(PropertyKey.sandwichKey) as! [RestoSandwich]
        self.menus = aDecoder.decodeObjectForKey(PropertyKey.menusKey) as! RestoMenus
        self.selectedResto = aDecoder.decodeObjectForKey(PropertyKey.selectedRestoKey) as! String
        self.menusLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.menusLastUpdatedKey) as? NSDate
        self.locationsLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.locationLastUpdatedKey) as? NSDate
        self.sandwichesLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.sandwichLastUpdatedKey) as? NSDate

        super.init(storagePath: Config.RestoStoreArchive.path!)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(_locations, forKey: PropertyKey.locationsKey)
        aCoder.encodeObject(_sandwiches, forKey: PropertyKey.sandwichKey)
        aCoder.encodeObject(menus, forKey: PropertyKey.menusKey)
        aCoder.encodeObject(selectedResto, forKey: PropertyKey.selectedRestoKey)
        aCoder.encodeObject(menusLastUpdated, forKey: PropertyKey.menusLastUpdatedKey)
        aCoder.encodeObject(locationsLastUpdated, forKey: PropertyKey.locationLastUpdatedKey)
        aCoder.encodeObject(sandwichesLastUpdated, forKey: PropertyKey.sandwichLastUpdatedKey)
    }

    func menuForDay(day: NSDate) -> RestoMenu? {
        let day = day.dateAtStartOfDay()

        let menu = menus[day]
        if let menusLastUpdated = self.menusLastUpdated {
            self.updateMenus(menusLastUpdated)
        } else {
            self.updateMenus(NSDate(), forceUpdate: true)
        }
        return menu
    }

    func updateMenus(lastUpdated: NSDate, forceUpdate: Bool = false) {
        let url =  APIConfig.Zeus2_0 + "resto/menu/\(self.selectedResto)/overview.json"

        self.updateResource(url, notificationName: RestoStoreDidReceiveMenuNotification, lastUpdated: lastUpdated, forceUpdate: forceUpdate) { (menus: [RestoMenu]) -> Void in
            self.menus = [:] // Remove old menus
            for menu in menus {
                self.menus[menu.date] = menu
            }
            self.menusLastUpdated = NSDate()
        }
    }

    func updateLocations() {
        let url = APIConfig.Zeus2_0 + "resto/meta.json"
        var lastUpdated = NSDate()
        var forceUpdate = true
        if let locationsLastUpdated = self.locationsLastUpdated {
            lastUpdated = locationsLastUpdated
            forceUpdate = false
        }
        self.updateResource(url, notificationName: RestoStoreDidUpdateInfoNotification, lastUpdated: lastUpdated, forceUpdate: forceUpdate, keyPath: "locations") { (locations: [RestoLocation]) -> Void in
            self._locations = locations
            self.locationsLastUpdated = NSDate()
        }
    }

    func updateSandwiches() {
        let url = APIConfig.Zeus2_0 + "resto/sandwiches.json"

        var lastUpdated = NSDate()
        var forceUpdate = true
        if let locationsLastUpdated = self.sandwichesLastUpdated {
            lastUpdated = locationsLastUpdated
            forceUpdate = false
        }
        self.updateResource(url, notificationName: RestoStoreDidUpdateSandwichesNotification, lastUpdated: lastUpdated, forceUpdate: forceUpdate) { (sandwiches: [RestoSandwich]) -> Void in
            self._sandwiches = sandwiches
            self.sandwichesLastUpdated = NSDate()
        }

    }

    struct PropertyKey {
        static let locationsKey = "locations"
        static let sandwichKey = "sandwich"
        static let menusKey = "menus"
        static let selectedRestoKey = "selectedResto"
        static let locationLastUpdatedKey = "locationsLastUpdated"
        static let sandwichLastUpdatedKey = "sandwichLastUpdated"
        static let menusLastUpdatedKey = "menusLastUpdated"
    }
}

extension RestoStore: FeedItemProtocol {
    func feedItems() -> [FeedItem] {
        var day = NSDate()
        if day.hour > 20 {
            day = day.dateByAddingDays(1)
        }
        var feedItems = [FeedItem]()
        
        // Find the next x days to display
        while (feedItems.count < 5) { //TODO: replace with var
            if day.isTypicallyWorkday() {
                var menu = menuForDay(day)
                
                if (menu == nil) {
                    menu = RestoMenu(date: day, open: false)
                }
                
                feedItems.append(FeedItem(itemType: .RestoItem, object: menu, priority: 1000 - 100*feedItems.count))
            }
            day = day.dateByAddingDays(1)
        }
        
        return feedItems
    }
}
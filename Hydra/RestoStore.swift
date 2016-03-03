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

    init() {
        super.init(storagePath: Config.RestoStoreArchive.path!)
    }

    required init?(coder aDecoder: NSCoder) {
        self.locations = aDecoder.decodeObjectForKey(PropertyKey.locationsKey) as? [RestoLocation]
        self.sandwiches = aDecoder.decodeObjectForKey(PropertyKey.sandwichKey) as? [RestoSandwich]
        self.menus = aDecoder.decodeObjectForKey(PropertyKey.menusKey) as! RestoMenus
        self.selectedResto = aDecoder.decodeObjectForKey(PropertyKey.selectedRestoKey) as! String
        self.locationsLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.locationLastUpdatedKey) as? NSDate
        self.sandwichesLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.sandwichLastUpdatedKey) as? NSDate

        super.init(storagePath: Config.RestoStoreArchive.path!)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(locations, forKey: PropertyKey.locationsKey)
        aCoder.encodeObject(sandwiches, forKey: PropertyKey.sandwichKey)
        aCoder.encodeObject(menus, forKey: PropertyKey.menusKey)
        aCoder.encodeObject(selectedResto, forKey: PropertyKey.selectedRestoKey)
        aCoder.encodeObject(locationsLastUpdated, forKey: PropertyKey.locationLastUpdatedKey)
        aCoder.encodeObject(sandwichesLastUpdated, forKey: PropertyKey.sandwichLastUpdatedKey)
    }

    var locations: [RestoLocation]?
    var sandwiches: [RestoSandwich]?
    var menus: RestoMenus = [:]
    var selectedResto: String = "nl"

    var locationsLastUpdated: NSDate?
    var sandwichesLastUpdated: NSDate?

    func menuForDay(day: NSDate) -> RestoMenu? {
        let day = day.dateAtStartOfDay()
        let menu = menus[day]

        self.updateMenuForDate(day, lastUpdated: menu?.lastUpdated)
        return menu
    }

    func updateMenuForDate(date: NSDate, lastUpdated: NSDate?) {
        if let lastUpdated = lastUpdated where NSDate().dateBySubtractingHours(1).isEarlierThanDate(lastUpdated){
            return
        }

        let url =  APIConfig.Zeus2_0 + "resto/menu/\(selectedResto)/\(date.year)/\(date.month)/\(date.day).json"

        if currentRequests.contains(url) {
            return
        }

        currentRequests.insert(url)

        Alamofire.request(.GET, url).responseObject { (response: Response<RestoMenu, NSError>) -> Void in
            if response.result.isFailure {
                self.handleError(response.result.error!)
                return
            }
            if let menu = response.result.value {
                self.menus[date] = menu
                self.markStorageOutdated()
                self.saveLater()
            }

            self.doLater(function: { () -> Void in
                self.currentRequests.remove(url)
            })
        }
    }

    struct PropertyKey {
        static let locationsKey = "locations"
        static let sandwichKey = "sandwich"
        static let menusKey = "menus"
        static let selectedRestoKey = "selectedResto"
        static let locationLastUpdatedKey = "locationsLastUpdated"
        static let sandwichLastUpdatedKey = "sandwichLastUpdated"
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
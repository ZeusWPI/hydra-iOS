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

typealias RestoMenus = [Date: RestoMenu]

class RestoStore: SavableStore, NSCoding {

    fileprivate static var _SharedStore: RestoStore?
    static var sharedStore: RestoStore {
        get {
            if let _SharedStore = _SharedStore {
                return _SharedStore
            } else {
                let restoStore = NSKeyedUnarchiver.unarchiveObject(withFile: Config.RestoStoreArchive.path) as? RestoStore
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

    fileprivate var _locations: [RestoLocation] = []
    var locations: [RestoLocation] {
        get {
            self.updateLocations()
            return self._locations
        }
    }
    fileprivate var _sandwiches: [RestoSandwich] = []
    var sandwiches: [RestoSandwich] {
        get {
            self.updateSandwiches()
            return self._sandwiches
        }
    }
    var menus: RestoMenus = [:]
    var selectedResto: RestoLocation = RestoLocation(name: "Resto De Brug",
                                                     address: "Sint-Pietersnieuwstraat 45",
                                                     type: .Resto,
                                                     latitude: 51.045613,
                                                     longitude: 3.727147,
                                                     endpoint: "nl") {
        didSet {
            if selectedResto.endpoint != oldValue.endpoint {
                menusLastUpdated = Date(timeIntervalSince1970: 0)
                menus = [:]
                updateMenus(menusLastUpdated!)
            }
        }
    }

    var menusLastUpdated: Date?
    var locationsLastUpdated: Date?
    var sandwichesLastUpdated: Date?

    init() {
        super.init(storagePath: Config.RestoStoreArchive.path)
    }

    required init?(coder aDecoder: NSCoder) {
        guard let locations = aDecoder.decodeObject(forKey: PropertyKey.locationsKey) as? [RestoLocation],
              let sandwiches = aDecoder.decodeObject(forKey: PropertyKey.sandwichKey) as? [RestoSandwich],
              let menus = aDecoder.decodeObject(forKey: PropertyKey.menusKey) as? RestoMenus,
              let selectedResto = aDecoder.decodeObject(forKey: PropertyKey.selectedRestoKey) as? RestoLocation else {
                return nil
        }

        self._locations = locations
        self._sandwiches = sandwiches
        self.menus = menus
        self.selectedResto = selectedResto

        self.menusLastUpdated = aDecoder.decodeObject(forKey: PropertyKey.menusLastUpdatedKey) as? Date
        self.locationsLastUpdated = aDecoder.decodeObject(forKey: PropertyKey.locationLastUpdatedKey) as? Date
        self.sandwichesLastUpdated = aDecoder.decodeObject(forKey: PropertyKey.sandwichLastUpdatedKey) as? Date

        super.init(storagePath: Config.RestoStoreArchive.path)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(_locations, forKey: PropertyKey.locationsKey)
        aCoder.encode(_sandwiches, forKey: PropertyKey.sandwichKey)
        aCoder.encode(menus, forKey: PropertyKey.menusKey)
        aCoder.encode(selectedResto, forKey: PropertyKey.selectedRestoKey)
        aCoder.encode(menusLastUpdated, forKey: PropertyKey.menusLastUpdatedKey)
        aCoder.encode(locationsLastUpdated, forKey: PropertyKey.locationLastUpdatedKey)
        aCoder.encode(sandwichesLastUpdated, forKey: PropertyKey.sandwichLastUpdatedKey)
    }

    func menuForDay(_ day: Date) -> RestoMenu? {
        let day = (day as NSDate).atStartOfDay()

        let menu = menus[day!]
        if let menusLastUpdated = self.menusLastUpdated {
            self.updateMenus(menusLastUpdated)
        } else {
            self.updateMenus(Date(), forceUpdate: true)
        }
        return menu
    }

    func updateMenus(_ lastUpdated: Date, forceUpdate: Bool = false) {
        let url =  APIConfig.Zeus2_0 + "resto/menu/\(self.selectedResto.endpoint)/overview.json"

        self.updateResource(url, notificationName: RestoStoreDidReceiveMenuNotification, lastUpdated: lastUpdated, forceUpdate: forceUpdate) { (menus: [RestoMenu]) -> Void in
            self.menus = [:] // Remove old menus
            for menu in menus {
                self.menus[menu.date] = menu
            }
            self.menusLastUpdated = Date()
        }
    }

    func updateLocations() {
        let url = APIConfig.Zeus2_0 + "resto/meta.json"
        var lastUpdated = Date()
        var forceUpdate = true
        if let locationsLastUpdated = self.locationsLastUpdated {
            lastUpdated = locationsLastUpdated
            forceUpdate = false
        }
        self.updateResource(url, notificationName: RestoStoreDidUpdateInfoNotification, lastUpdated: lastUpdated, forceUpdate: forceUpdate, keyPath: "locations") { (locations: [RestoLocation]) -> Void in
            self._locations = locations
            self.locationsLastUpdated = Date()
        }
    }

    func updateSandwiches() {
        let url = APIConfig.Zeus2_0 + "resto/sandwiches.json"

        var lastUpdated = Date()
        var forceUpdate = true
        if let locationsLastUpdated = self.sandwichesLastUpdated {
            lastUpdated = locationsLastUpdated
            forceUpdate = false
        }
        self.updateResource(url, notificationName: RestoStoreDidUpdateSandwichesNotification, lastUpdated: lastUpdated, forceUpdate: forceUpdate) { (sandwiches: [RestoSandwich]) -> Void in
            self._sandwiches = sandwiches
            self.sandwichesLastUpdated = Date()
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
        var day = Date()
        if (day as NSDate).hour > 20 {
            day = (day as NSDate).addingDays(1)
        }
        var feedItems = [FeedItem]()

        if !PreferencesService.sharedService.showRestoInFeed {
            return feedItems
        }

        // Find the next x days to display
        while (feedItems.count < 5) { //TODO: replace with var
            if (day as NSDate).isTypicallyWorkday() {
                var menu = menuForDay(day)

                if (menu == nil) {
                    menu = RestoMenu(date: day, open: false)
                }

                feedItems.append(FeedItem(itemType: .restoItem, object: menu, priority: 1000 - 100*feedItems.count))
            }
            day = (day as NSDate).addingDays(1)
        }

        return feedItems
    }
}

//
//  RestoStore.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 20/11/2015.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation
import Alamofire

let RestoStoreDidReceiveMenuNotification = "RestoStoreDidReceiveMenuNotification"
let RestoStoreDidUpdateInfoNotification = "RestoStoreDidUpdateInfoNotification"
let RestoStoreDidUpdateSandwichesNotification = "RestoStoreDidUpdateSandwichesNotification"

typealias RestoMenus = [Date: RestoMenu]

class RestoStore: SavableStore, Codable {

    fileprivate static var _shared: RestoStore?
    static var shared: RestoStore {
        get {
            if let shared = _shared {
                return shared
            } /*else {
                let restoStore = NSKeyedUnarchiver.unarchiveObject(withFile: Config.RestoStoreArchive.path) as? RestoStore
                if let restoStore = restoStore {
                    _shared = restoStore
                    return _shared!
                }
            }*/
            // initialize new one
            _shared = RestoStore()
            return _shared!
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
                self.postNotification(RestoStoreDidReceiveMenuNotification)
                updateMenus(menusLastUpdated!)
            }
        }
    }

    var menusLastUpdated: Date?
    var locationsLastUpdated: Date?
    var sandwichesLastUpdated: Date?
    
    override func syncStorage() {
        super.syncStorage(obj: self, storageURL: Config.RestoStoreArchive)
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
        guard let endpoint = self.selectedResto.endpoint else {
            return
        }
        
        let url =  APIConfig.Zeus2_0 + "resto/menu/\(endpoint)/overview.json"
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dds = JSONDecoder.DateDecodingStrategy.formatted(df)
        self.updateResource(url, notificationName: RestoStoreDidReceiveMenuNotification, lastUpdated: lastUpdated, forceUpdate: forceUpdate, dateDecodingStrategy: dds) { (menus: [RestoMenu]) -> Void in
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
        self.updateResource(url, notificationName: RestoStoreDidUpdateInfoNotification, lastUpdated: lastUpdated, forceUpdate: forceUpdate) { (locations: RestoLocations) -> Void in
            self._locations = locations.locations
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

fileprivate struct RestoLocations: Codable {
    let locations: [RestoLocation]
}

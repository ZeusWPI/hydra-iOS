//
//  AssociationStore.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 27/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import Alamofire

let AssociationStoreDidUpdateNewsNotification = "AssociationStoreDidUpdateNewsNotification"
let AssociationStoreDidUpdateActivitiesNotification = "AssociationStoreDidUpdateActivitiesNotification"
let AssociationStoreDidUpdateAssociationsNotification = "AssociationStoreDidUpdateAssociationsNotification"

@objc class AssociationStore: SavableStore, Codable {

    fileprivate static var _shared: AssociationStore?
    @objc static var shared: AssociationStore {
        get {
            if let shared = _shared {
                return shared
            }
            _shared = SavableStore.loadStore(self, from: Config.AssociationStoreArchive)
            return _shared!
        }
    }
    
    var associationLookup: [String: Association] = [:]

    fileprivate var _associations: [Association] = []
    @objc var associations: [Association] {
        get {
            self.reloadAssociations()
            return self._associations
        }
    }
    fileprivate var _activities: [Activity] = []
    var activities: [Activity] {
        get {
            self.reloadActivities()
            return self._activities
        }
    }
    fileprivate var _newsItems: [NewsItem] = []
    var newsItems: [NewsItem] {
        get {
            self.reloadNewsItems()
            return self._newsItems
        }
    }
    
    fileprivate var _ugentNewsItems: [UGentNewsItem] = []
    var ugentNewsItems: [UGentNewsItem] {
        get {
            self.reloadUGentNewsItems()
            return self._ugentNewsItems
        }
    }

    var associationsLastUpdated: Date = Date(timeIntervalSince1970: 0)
    var activitiesLastUpdated: Date = Date(timeIntervalSince1970: 0)
    var newsLastUpdated: Date = Date(timeIntervalSince1970: 0)
    var ugentNewsLastUpdated: Date = Date(timeIntervalSince1970: 0)

    override func syncStorage() {
        super.syncStorage(obj: self, storageURL: Config.AssociationStoreArchive)
    }
    
    /*func sharedInit() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(AssociationStore.facebookEventUpdated(_:)), name: NSNotification.Name(rawValue: FacebookEventDidUpdateNotification), object: nil)
    }*/
    
    fileprivate static func createAssociationLookup(_ associations: [Association]) -> [String: Association] {
        var associationsLookup = [String: Association]()
        for association in associations {
            associationsLookup[association.internalName] = association
        }
        return associationsLookup
    }

    @objc func associationWithName(_ internalName: String) -> Association? {
        let association = associationLookup[internalName]
        return association
    }

    func reloadAssociations(_ forceUpdate: Bool = false) {
        updateResource(APIConfig.DSA + "2.0/associations.json",
            notificationName: AssociationStoreDidUpdateAssociationsNotification,
            lastUpdated: self.associationsLastUpdated,
            forceUpdate: forceUpdate) { (associations: [Association]) -> () in
            print("Updating associations")
            self._associations = associations
            self.associationsLastUpdated = Date()

            self.associationLookup = AssociationStore.createAssociationLookup(associations)
        }
    }

    func reloadActivities(_ forceUpdate: Bool = false) {
        updateResource(APIConfig.DSA + "2.0/all_activities.json",
                       notificationName: AssociationStoreDidUpdateActivitiesNotification,
                       lastUpdated: self.activitiesLastUpdated,
                       forceUpdate: forceUpdate) { (activities: [Activity]) -> () in
            print("Updating activities")
            var facebookEvents: Dictionary<String, FacebookEvent> = [:]
            // cache all facebookEvents to dict
            for activity in self._activities where activity.hasFacebookEvent() {
                facebookEvents[activity.facebookId!] = activity.facebookEvent
            }

            // add them to the new objects
            /*for activity in activities where activity.facebookId != nil {
                if let facebookEvent = facebookEvents[activity.facebookId!] {
                    //TODO: activity.facebookEvent = facebookEvent
                }
            }*/
            self._activities = activities
            self.activitiesLastUpdated = Date()
        }
    }

    func reloadNewsItems(_ forceUpdate: Bool = false) {
        updateResource(APIConfig.DSA + "3.0/old_news.json", notificationName: AssociationStoreDidUpdateNewsNotification, lastUpdated: self.newsLastUpdated, forceUpdate: forceUpdate) { (newsItems: [NewsItem]) -> () in
            print("Updating News Items")
            let readItems = Set<Int>(self._newsItems.filter({ $0.read }).map({ $0.internalIdentifier}))
            for item in newsItems {
                if readItems.contains(item.internalIdentifier) {
                    item.read = true
                }
            }

            self._newsItems = newsItems.sorted(by: { $0.date > $1.date })
            self.newsLastUpdated = Date()
        }
    }
    
    func reloadUGentNewsItems(_ forceUpdate: Bool = false) {
        updateResource(APIConfig.DSA + "3.0/recent_news.json", notificationName: AssociationStoreDidUpdateNewsNotification, lastUpdated: self.newsLastUpdated, forceUpdate: forceUpdate) { (newsItems: [UGentNewsItem]) -> () in
            print("Updating News Items")
            let readItems = Set<String>(self._ugentNewsItems.filter({ $0.read }).map({ $0.identifier}))
            for item in newsItems {
                if readItems.contains(item.identifier) {
                    item.read = true
                }
            }
            
            self._ugentNewsItems = newsItems.sorted(by: { $0.date > $1.date })
            self.newsLastUpdated = Date()
        }
    }

    // MARK: notifications
    @objc func facebookEventUpdated(_ notification: Notification) {
        self.markStorageOutdated()
        self.doLater {
            self.syncStorage()
        }
    }
}

// MARK: Implement FeedItemProtocol
extension AssociationStore: FeedItemProtocol {
    func feedItems() -> [FeedItem] {
        return getActivities() + getNewsItems() + getUGentNewsItems()
    }

    fileprivate func getActivities() -> [FeedItem] {
        var feedItems = [FeedItem]()
        let preferencesService = PreferencesService.sharedService
        var filter: ((Activity) -> (Bool))
        if preferencesService.showActivitiesInFeed {
            if preferencesService.filterAssociations {
                let associations = preferencesService.preferredAssociations
                filter = { activity in activity.highlighted || associations.contains { activity.association.internalName == ($0) } }
            } else {
                filter = { _ in true }
            }
        } else {
            filter = { $0.highlighted }
            feedItems.append(FeedItem(itemType: .associationsSettingsItem, object: nil, priority: 850))
        }

        for activity in activities.filter(filter) {
            // Force load facebookEvent
            if let facebookEvent = activity.facebookEvent {
                facebookEvent.update()
            }
            var priority = 950 //TODO: calculate priorities, with more options
            priority -= max((activity.start as NSDate).hours(after: Date()), 0)
            if priority > 0 {
                feedItems.append(FeedItem(itemType: .activityItem, object: activity, priority: priority))
            }
        }
        return feedItems
    }

    fileprivate func getNewsItems() -> [FeedItem] {
        var feedItems = [FeedItem]()
        var filter: ((NewsItem) -> (Bool))

        if PreferencesService.sharedService.showNewsInFeed {
            filter = { _ in true }
        } else {
            filter = { $0.highlighted }
        }

        for newsItem in newsItems.filter(filter) {
            var priority = 999
            let daysOld = (newsItem.date as NSDate).days(before: Date())
            if newsItem.highlighted {
                priority -= 25*daysOld
            } else {
                priority -= 90*daysOld
            }

            if priority > 0 {
                feedItems.append(FeedItem(itemType: .newsItem, object: newsItem, priority: priority))
            }
        }

        return feedItems
    }
    
    fileprivate func getUGentNewsItems() -> [FeedItem] {
        var feedItems = [FeedItem]()
        
        /*if !PreferencesService.sharedService.showNewsInFeed {
           return []
        }*/
        
        for newsItem in ugentNewsItems {
            var priority = 999
            let daysOld = (newsItem.date as NSDate).days(before: Date())
            priority -= 25*daysOld
            
            if priority > 0 {
                feedItems.append(FeedItem(itemType: .ugentNewsItem, object: newsItem, priority: priority))
            }
        }
        
        return feedItems
    }

}

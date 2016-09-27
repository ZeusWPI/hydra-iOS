//
//  AssociationStore.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 27/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

let AssociationStoreDidUpdateNewsNotification = "AssociationStoreDidUpdateNewsNotification"
let AssociationStoreDidUpdateActivitiesNotification = "AssociationStoreDidUpdateActivitiesNotification"
let AssociationStoreDidUpdateAssociationsNotification = "AssociationStoreDidUpdateAssociationsNotification"

class AssociationStore: SavableStore, NSCoding {
    
    fileprivate static var _SharedStore: AssociationStore?
    static var sharedStore: AssociationStore {
        get {
            //TODO: make lazy, and catch NSKeyedUnarchiver errors
            if let _SharedStore = _SharedStore {
                return _SharedStore
            } else  {
                let associationStore = NSKeyedUnarchiver.unarchiveObject(withFile: Config.AssociationStoreArchive.path) as? AssociationStore
                if let associationStore = associationStore {
                    _SharedStore = associationStore
                    return _SharedStore!
                }
            }
            // initialize new one
            _SharedStore = AssociationStore()
            return _SharedStore!
        }
    }
    
    var associationLookup: [String: Association]

    fileprivate var _associations: [Association]
    var associations: [Association] {
        get {
            self.reloadAssociations()
            return self._associations
        }
    }
    fileprivate var _activities: [Activity]
    var activities: [Activity] {
        get {
            self.reloadActivities()
            return self._activities
        }
    }
    fileprivate var _newsItems: [NewsItem]
    var newsItems: [NewsItem] {
        get {
            self.reloadNewsItems()
            return self._newsItems
        }
    }
    
    var associationsLastUpdated: Date
    var activitiesLastUpdated: Date
    var newsLastUpdated: Date

    init() {
        associationsLastUpdated = Date(timeIntervalSince1970: 0)
        activitiesLastUpdated = Date(timeIntervalSince1970: 0)
        newsLastUpdated = Date(timeIntervalSince1970: 0)
        
        associationLookup = [:]
        _associations = []
        _activities = []
        _newsItems = []

        super.init(storagePath: Config.AssociationStoreArchive.path)
        self.sharedInit()
    }

    func sharedInit() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(AssociationStore.facebookEventUpdated(_:)), name: NSNotification.Name(rawValue: FacebookEventDidUpdateNotification), object: nil)
    }
    
    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        guard let associations = aDecoder.decodeObject(forKey: PropertyKey.associationsKey) as? [Association],
            let activities = aDecoder.decodeObject(forKey: PropertyKey.activitiesKey) as? [Activity],
            let newsItems = aDecoder.decodeObject(forKey: PropertyKey.newsItemsKey) as? [NewsItem],
            let associationsLastUpdated = aDecoder.decodeObject(forKey: PropertyKey.associationsLastUpdatedKey) as? Date,
            let activitiesLastUpdated = aDecoder.decodeObject(forKey: PropertyKey.activitiesLastUpdatedKey) as? Date,
            let newsLastUpdated = aDecoder.decodeObject(forKey: PropertyKey.newsItemsLastUpdatedKey) as? Date else {
                return nil
        }

        self._associations = associations
        self._activities = activities
        self._newsItems = newsItems
        self.associationsLastUpdated = associationsLastUpdated
        self.activitiesLastUpdated = activitiesLastUpdated
        self.newsLastUpdated = newsLastUpdated

        associationLookup = AssociationStore.createAssociationLookup(_associations)

        super.init(storagePath: Config.AssociationStoreArchive.path)
        self.sharedInit()
    }

    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(_associations, forKey: PropertyKey.associationsKey)
        aCoder.encode(_activities, forKey: PropertyKey.activitiesKey)
        aCoder.encode(_newsItems, forKey: PropertyKey.newsItemsKey)
        
        aCoder.encode(associationsLastUpdated, forKey: PropertyKey.associationsLastUpdatedKey)
        aCoder.encode(activitiesLastUpdated, forKey: PropertyKey.activitiesLastUpdatedKey)
        aCoder.encode(newsLastUpdated, forKey: PropertyKey.newsItemsLastUpdatedKey)
    }
    
    
    fileprivate static func createAssociationLookup(_ associations: [Association]) -> [String: Association] {
        var associationsLookup = [String: Association]()
        for association in associations {
            associationsLookup[association.internalName] = association
        }
        return associationsLookup
    }
    
    func associationWithName(_ internalName: String) -> Association? {
        let association = associationLookup[internalName]
        return association
    }
    
    func reloadAssociations(_ forceUpdate: Bool = false) {
        updateResource(APIConfig.DSA + "2.0/associations.json",
            notificationName: AssociationStoreDidUpdateAssociationsNotification,
            lastUpdated: self.associationsLastUpdated,
            forceUpdate: forceUpdate) { (associations:[Association]) -> () in
            print("Updating associations")
            self._associations = associations
            self.associationsLastUpdated = Date()
            
            self.associationLookup = AssociationStore.createAssociationLookup(associations)
        }
    }

    func reloadActivities(_ forceUpdate: Bool = false) {
        updateResource(APIConfig.DSA + "2.0/all_activities.json", notificationName: AssociationStoreDidUpdateActivitiesNotification,lastUpdated: self.activitiesLastUpdated, forceUpdate: forceUpdate) { (activities: [Activity]) -> () in
            print("Updating activities")
            var facebookEvents: Dictionary<String, FacebookEvent> = [:]
            // cache all facebookEvents to dict
            for activity in self._activities where activity.hasFacebookEvent() {
                facebookEvents[activity.facebookId!] = activity.facebookEvent
            }

            // add them to the new objects
            for activity in activities where activity.facebookId != nil{
                if let facebookEvent = facebookEvents[activity.facebookId!] {
                    activity.facebookEvent = facebookEvent
                }
            }
            self._activities = activities
            self.activitiesLastUpdated = Date()
        }
    }

    func reloadNewsItems(_ forceUpdate: Bool = false) {
        updateResource(APIConfig.DSA + "2.0/all_news.json", notificationName: AssociationStoreDidUpdateNewsNotification,lastUpdated: self.newsLastUpdated, forceUpdate: forceUpdate) { (newsItems:[NewsItem]) -> () in
            print("Updating News Items")
            let readItems = Set<Int>(self._newsItems.filter({ $0.read }).map({ $0.internalIdentifier}))
            for item in newsItems {
                if readItems.contains(item.internalIdentifier) {
                    item.read = true
                }
            }

            self._newsItems = newsItems
            self.newsLastUpdated = Date()
        }
    }
    
    // MARK: notifications
    func facebookEventUpdated(_ notification: Notification) {
        self.markStorageOutdated()
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).asyncAfter(deadline: DispatchTime.now() + Double(Int64(10*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.syncStorage()
        }
    }
    
    // MARK: field information struct
    struct PropertyKey {
        static let associationsKey = "associations"
        static let activitiesKey = "activities"
        static let newsItemsKey = "newsItems"

        static let associationsLastUpdatedKey = "associationsLastUpdated"
        static let activitiesLastUpdatedKey = "activitiesLastUpdated"
        static let newsItemsLastUpdatedKey = "newsItemsLastUpdated"
    }
}

// MARK: Implement FeedItemProtocol
extension AssociationStore: FeedItemProtocol {
    func feedItems() -> [FeedItem] {
        return getActivities() + getNewsItems()
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
}

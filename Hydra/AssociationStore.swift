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

let TIME_BETWEEN_REFRESH: NSTimeInterval = 60 * 15


let AssociationStoreDidUpdateNewsNotification = "AssociationStoreDidUpdateNewsNotification"
let AssociationStoreDidUpdateActivitiesNotification = "AssociationStoreDidUpdateActivitiesNotification"
let AssociationStoreDidUpdateAssociationsNotification = "AssociationStoreDidUpdateAssociationsNotification"

class AssociationStore: SavableStore, NSCoding {
    
    private static var _SharedStore: AssociationStore?
    static var sharedStore: AssociationStore {
        get {
            //TODO: make lazy, and catch NSKeyedUnarchiver errors
            if let _SharedStore = _SharedStore {
                return _SharedStore
            } else  {
                let associationStore = NSKeyedUnarchiver.unarchiveObjectWithFile(Config.AssociationStoreArchive.path!) as? AssociationStore
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

    private var _associations: [Association]
    var associations: [Association] {
        get {
            self.reloadAssociations()
            return self._associations
        }
    }
    private var _activities: [Activity]
    var activities: [Activity] {
        get {
            self.reloadActivities()
            return self._activities
        }
    }
    private var _newsItems: [NewsItem]
    var newsItems: [NewsItem] {
        get {
            self.reloadNewsItems()
            return self._newsItems
        }
    }
    
    var associationsLastUpdated: NSDate
    var activitiesLastUpdated: NSDate
    var newsLastUpdated: NSDate

    init() {
        associationsLastUpdated = NSDate(timeIntervalSince1970: 0)
        activitiesLastUpdated = NSDate(timeIntervalSince1970: 0)
        newsLastUpdated = NSDate(timeIntervalSince1970: 0)
        
        associationLookup = [:]
        _associations = []
        _activities = []
        _newsItems = []

        super.init(storagePath: Config.AssociationStoreArchive.path!)
        self.sharedInit()
    }

    func sharedInit() {
        //let center = NSNotificationCenter.defaultCenter()
        //center.addObserver(self, selector: "facebookEventUpdated:", name: FacebookEventDidUpdateNotification, object: nil)
    }
    
    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        associationsLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.associationsLastUpdatedKey) as! NSDate
        activitiesLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.activitiesLastUpdatedKey) as! NSDate
        newsLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.newsItemsLastUpdatedKey) as! NSDate
        _associations = aDecoder.decodeObjectForKey(PropertyKey.associationsKey) as! [Association]
        _activities = aDecoder.decodeObjectForKey(PropertyKey.activitiesKey) as! [Activity]
        _newsItems = aDecoder.decodeObjectForKey(PropertyKey.newsItemsKey) as! [NewsItem]

        associationLookup = AssociationStore.createAssociationLookup(_associations)

        super.init(storagePath: Config.AssociationStoreArchive.path!)
        self.sharedInit()
    }

    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(associations, forKey: PropertyKey.associationsKey)
        aCoder.encodeObject(activities, forKey: PropertyKey.activitiesKey)
        aCoder.encodeObject(newsItems, forKey: PropertyKey.newsItemsKey)
        
        aCoder.encodeObject(associationsLastUpdated, forKey: PropertyKey.associationsLastUpdatedKey)
        aCoder.encodeObject(activitiesLastUpdated, forKey: PropertyKey.activitiesLastUpdatedKey)
        aCoder.encodeObject(newsLastUpdated, forKey: PropertyKey.newsItemsLastUpdatedKey)
    }
    
    
    private static func createAssociationLookup(associations: [Association]) -> [String: Association] {
        var associationsLookup = [String: Association]()
        for association in associations {
            associationsLookup[association.internalName] = association
        }
        return associationsLookup
    }
    
    func associationWithName(internalName: String) -> Association? {
        let association = associationLookup[internalName]
        return association
    }
    
    func reloadAssociations(forceUpdate: Bool = false) {
        updateResource(APIConfig.DSA + "1.0/associations.json",
            notificationName: AssociationStoreDidUpdateAssociationsNotification,
            lastUpdated: self.associationsLastUpdated,
            forceUpdate: forceUpdate) { (associations:[Association]) -> () in
            print("Updating associations")
            self._associations = associations
            self.associationsLastUpdated = NSDate()
            
            self.associationLookup = AssociationStore.createAssociationLookup(associations)
        }
    }

    func reloadActivities(forceUpdate: Bool = false) {
        updateResource(APIConfig.DSA + "1.0/all_activities.json", notificationName: AssociationStoreDidUpdateActivitiesNotification,lastUpdated: self.activitiesLastUpdated, forceUpdate: forceUpdate) { (activities: [Activity]) -> () in
            print("Updating activities")
            //TODO: save facebook event classes
            self._activities = activities
            self.activitiesLastUpdated = NSDate()
        }
    }

    func reloadNewsItems(forceUpdate: Bool = false) {
        updateResource(APIConfig.DSA + "1.0/all_news.json", notificationName: AssociationStoreDidUpdateNewsNotification,lastUpdated: self.newsLastUpdated, forceUpdate: forceUpdate) { (newsItems:[NewsItem]) -> () in
            print("Updating News Items")
            let readItems = Set<Int>(self._newsItems.filter({ $0.read }).map({ $0.internalIdentifier}))
            for item in newsItems {
                if readItems.contains(item.internalIdentifier) {
                    item.read = true
                }
            }

            self._newsItems = newsItems
            self.newsLastUpdated = NSDate()
        }
    }

    private func updateResource<T: Mappable>(resource: String, notificationName: String, lastUpdated: NSDate, forceUpdate: Bool, completionHandler: ([T]-> Void)) {
        if lastUpdated.timeIntervalSinceNow > -TIME_BETWEEN_REFRESH && !forceUpdate {
            return
        }

        if currentRequests.contains(resource) {
            self.postNotification(notificationName)
            return
        }
        currentRequests.insert(resource)
        Alamofire.request(.GET, resource).responseArray(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { (response: Response<[T], NSError>) -> Void in
            if let value = response.result.value where response.result.isSuccess {
                completionHandler(value)
                self.markStorageOutdated()
                self.syncStorage()
            } else {
                //TODO: Handle error
            }
            self.postNotification(notificationName)
            self.currentRequests.remove(resource)
        }
    }
    
    // MARK: notifications
    func facebookEventUpdated(notification: NSNotification) {
        self.markStorageOutdated()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10*Double(NSEC_PER_SEC))), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
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

    private func getActivities() -> [FeedItem] {
        var feedItems = [FeedItem]()
        let preferencesService = PreferencesService.sharedService()
        var filter: ((Activity) -> (Bool))
        if preferencesService.filterAssociations {
            let associations = preferencesService.preferredAssociations
            filter = { activity in activity.highlighted || associations.contains { activity.association.internalName == ($0 as! String) } }
        } else {
            if preferencesService.showActivitiesInFeed {
                filter = { _ in true }
            } else {
                filter = { $0.highlighted }
                feedItems.append(FeedItem(itemType: .SettingsItem, object: nil, priority: 850))
            }
        }

        for activity in activities.filter(filter) {
            // Force load facebookEvent
            if let facebookEvent = activity.facebookEvent {
                facebookEvent.update()
            }
            var priority = 999 //TODO: calculate priorities, with more options
            priority -= activity.start.daysAfterDate(NSDate()) * 100
            if priority > 0 {
                feedItems.append(FeedItem(itemType: .ActivityItem, object: activity, priority: priority))
            }
        }
        return feedItems
    }

    private func getNewsItems() -> [FeedItem] {
        var feedItems = [FeedItem]()

        for newsItem in newsItems {
            var priority = 999
            let daysOld = newsItem.date.daysBeforeDate(NSDate())
            if newsItem.highlighted {
                priority -= 25*daysOld
            } else {
                priority -= 90*daysOld
            }

            if priority > 0 {
                feedItems.append(FeedItem(itemType: .NewsItem, object: newsItem, priority: priority))
            }
        }

        return feedItems
    }
}
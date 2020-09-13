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
    
    fileprivate static func createAssociationLookup(_ associations: [Association]) -> [String: Association] {
        var associationsLookup = [String: Association]()
        for association in associations {
            associationsLookup[association.abbreviation] = association
        }
        return associationsLookup
    }

    @objc func associationWithName(_ abbreviation: String) -> Association? {
        let association = associationLookup[abbreviation]
        return association
    }

    func reloadAssociations(_ forceUpdate: Bool = false) {
        updateResource(APIConfig.DSA + "verenigingen",
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
        updateResource(APIConfig.DSA + "activiteiten?page_size=100",
                       notificationName: AssociationStoreDidUpdateActivitiesNotification,
                       lastUpdated: self.activitiesLastUpdated,
                       forceUpdate: forceUpdate) { (activitiesResult: ActivitiesResult) -> () in
            print("Updating activities")
            
            self._activities = activitiesResult.page.entries
            self.activitiesLastUpdated = Date()
        }
    }
    
    func reloadUGentNewsItems(_ forceUpdate: Bool = false) {
        updateResource(APIConfig.UGent + "nl/actueel/overzicht/@@rss2json", notificationName: AssociationStoreDidUpdateNewsNotification, lastUpdated: self.newsLastUpdated, forceUpdate: forceUpdate) { (newsItems: [UGentNewsItem]) -> () in
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
}

// MARK: Implement FeedItemProtocol
extension AssociationStore: FeedItemProtocol {
    func feedItems() -> [FeedItem] {
        return getActivities() + getUGentNewsItems()
    }

    fileprivate func getActivities() -> [FeedItem] {
        var feedItems = [FeedItem]()
        let preferencesService = PreferencesService.sharedService
        var filter: ((Activity) -> (Bool))
        if preferencesService.showActivitiesInFeed {
            if preferencesService.filterAssociations {
                let associations = preferencesService.preferredAssociations
                filter = { activity in associations.contains { activity.association == ($0) } }
            } else {
                filter = { _ in true }
            }
        } else {
            filter = { _ in false }
            feedItems.append(FeedItem(itemType: .associationsSettingsItem, object: nil, priority: 850))
        }

        for activity in activities.filter(filter) {
            var priority = 950 //TODO: calculate priorities, with more options
            priority -= max((activity.start as NSDate).hours(after: Date()), 0)
            if priority > 0 {
                feedItems.append(FeedItem(itemType: .activityItem, object: activity, priority: priority))
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

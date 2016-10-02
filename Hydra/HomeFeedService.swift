//
//  HomeFeedService.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 31/07/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation

let HomeFeedDidUpdateFeedNotification = "HomeFeedDidUpdateFeedNotification"
let UpdateInterval: Double = 30 * 60 // half an hour

class HomeFeedService {
    
    static let sharedService = HomeFeedService()
    
    let associationStore = AssociationStore.sharedStore
    let restoStore = RestoStore.sharedStore
    let schamperStore = SchamperStore.sharedStore
    let preferencesService = PreferencesService.sharedService
    let specialEventStore = SpecialEventStore.sharedStore
    let minervaStore = MinervaStore.sharedStore
    let locationService = LocationService.sharedService

    var previousRefresh = Date()
    var previousNotificationDate = Date(timeIntervalSince1970: 0)
    
    fileprivate init() {
        refreshStores()
        locationService.updateLocation()
        
        let notifications = [RestoStoreDidReceiveMenuNotification, AssociationStoreDidUpdateActivitiesNotification, AssociationStoreDidUpdateNewsNotification, SchamperStoreDidUpdateArticlesNotification, SpecialEventStoreDidUpdateNotification, MinervaStoreDidUpdateCourseInfoNotification, PreferencesControllerDidUpdatePreferenceNotification]
        for notification in notifications {
             NotificationCenter.default.addObserver(self, selector: #selector(HomeFeedService.storeUpdatedNotification(_:)), name: NSNotification.Name(rawValue: notification), object: nil)
        }
    }
    
    
    @objc func storeUpdatedNotification(_ notification: Notification) {
        if (previousNotificationDate.addingTimeInterval(5) as NSDate).isEarlierThanDate(Date()) {
            previousNotificationDate = Date()
            doLater(4) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: HomeFeedDidUpdateFeedNotification), object: nil)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func refreshStoresIfNecessary()
    {
        if self.previousRefresh.timeIntervalSinceNow > -UpdateInterval {
            self.refreshStores()
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: HomeFeedDidUpdateFeedNotification), object: nil)
        }
    }
    
    func refreshStores() {
        previousRefresh = Date()
        associationStore.reloadActivities()
        associationStore.reloadNewsItems()
        
        _ = restoStore.menuForDay(Date())
        _ = restoStore.locations
        
        schamperStore.reloadArticles()

        specialEventStore.updateSpecialEvents()

        minervaStore.update()

        locationService.updateLocation()
    }
    
    func createFeed() -> [FeedItem] {
        var list = [FeedItem]()

        let feedItemProviders: [FeedItemProtocol] = [associationStore, schamperStore, restoStore, specialEventStore, minervaStore]

        for provider in feedItemProviders {
            list.append(contentsOf: provider.feedItems())
        }
        
        // Urgent.fm
        if preferencesService.showUrgentfmInFeed {
            list.append(FeedItem(itemType: .urgentItem, object: nil, priority: 825))
        }

        list.sort{ $0.priority > $1.priority }
        
        return list
    }

    func doLater(_ timeSec: Int = 1, function: @escaping (()->Void)) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(timeSec)*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            function()
        }
    }
}

protocol FeedItemProtocol {
    func feedItems() -> [FeedItem]
}

struct FeedItem {
    let itemType: FeedItemType
    let object: AnyObject?
    let priority: Int
    
    init(itemType: FeedItemType, object: AnyObject?, priority: Int) {
        self.itemType = itemType
        self.object = object
        self.priority = priority
    }
}

enum FeedItemType {
    case newsItem
    case activityItem
    case infoItem
    case restoItem
    case urgentItem
    case schamperNewsItem
    case associationsSettingsItem
    case specialEventItem
    case minervaSettingsItem
    case minervaAnnouncementItem
    case minervaCalendarItem
}

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

    let associationStore = AssociationStore.shared
    let restoStore = RestoStore.shared
    let schamperStore = SchamperStore.shared
    let preferencesService = PreferencesService.sharedService
    let specialEventStore = SpecialEventStore.shared
    let locationService = LocationService.sharedService

    var previousRefresh = Date()
    var previousNotificationDate = Date(timeIntervalSince1970: 0)

    fileprivate init() {
        refreshStores()
        locationService.updateLocation()

        let notifications = [RestoStoreDidReceiveMenuNotification, AssociationStoreDidUpdateActivitiesNotification, AssociationStoreDidUpdateNewsNotification, SchamperStoreDidUpdateArticlesNotification, SpecialEventStoreDidUpdateNotification, PreferencesControllerDidUpdatePreferenceNotification]
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

    func refreshStoresIfNecessary() {
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
        associationStore.reloadUGentNewsItems()

        _ = restoStore.menuForDay(Date())
        _ = restoStore.locations

        schamperStore.reloadArticles()

        specialEventStore.updateSpecialEvents()

        locationService.updateLocation()
    }

    func createFeed() -> [FeedItem] {
        var list = [FeedItem]()

        let feedItemProviders: [FeedItemProtocol] = [associationStore, schamperStore, restoStore, specialEventStore]

        for provider in feedItemProviders {
            list.append(contentsOf: provider.feedItems())
        }

        list.sort { $0.priority > $1.priority }

        return list
    }

    func doLater(_ timeSec: Double = 1, function: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + timeSec) { () -> Void in
            function()
        }
    }
}

protocol FeedItemProtocol {
    func feedItems() -> [FeedItem]
}

struct FeedItem {
    let itemType: FeedItemType
    let object: Any?
    let priority: Int

    init(itemType: FeedItemType, object: Any?, priority: Int) {
        self.itemType = itemType
        self.object = object
        self.priority = priority
    }
}

enum FeedItemType {
    case newsItem
    case ugentNewsItem
    case activityItem
    case infoItem
    case restoItem
    case schamperNewsItem
    case associationsSettingsItem
    case specialEventItem
}

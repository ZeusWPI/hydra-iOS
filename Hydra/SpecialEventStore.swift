//
//  SpecialEventStore.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 04/04/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

let SpecialEventStoreDidUpdateNotification = "SpecialEventStoreDidUpdateNotification"

class SpecialEventStore: SavableStore, NSCoding {

    fileprivate static var _SharedStore: SpecialEventStore?
    static var sharedStore: SpecialEventStore {
        get {
            //TODO: make lazy, and catch NSKeyedUnarchiver errors
            if let _SharedStore = _SharedStore {
                return _SharedStore
            } else {
                let specialEventStore = NSKeyedUnarchiver.unarchiveObject(withFile: Config.SpecialEventStoreArchive.path) as? SpecialEventStore
                if let specialEventStore = specialEventStore {
                    _SharedStore = specialEventStore
                    return _SharedStore!
                }
            }
            // initialize new one
            _SharedStore = SpecialEventStore()
            return _SharedStore!
        }
    }

    fileprivate var _specialEvents: [SpecialEvent] = []
    var specialEvents: [SpecialEvent] {
        get {
            self.updateSpecialEvents()
            return _specialEvents
        }
    }

    var specialEventsLastUpdated = Date(timeIntervalSince1970: 0)

    init() {
        super.init(storagePath: Config.SpecialEventStoreArchive.path)
    }

    func updateSpecialEvents(_ forced: Bool = false) {
        updateResource(APIConfig.Zeus2_0 + "association/special_events.json", notificationName: SpecialEventStoreDidUpdateNotification, lastUpdated: specialEventsLastUpdated, forceUpdate: forced, keyPath: "special-events") { (specialEvents: [SpecialEvent]) in
            self._specialEvents = specialEvents
            self.specialEventsLastUpdated = Date()
        }
    }

    // MARK: Conform to NSCoding
    required init?(coder aDecoder: NSCoder) {
        guard let specialEvents = aDecoder.decodeObject(forKey: PropertyKey.specialEventsKey) as? [SpecialEvent],
            let specialEventsLastUpdated = aDecoder.decodeObject(forKey: PropertyKey.specialEventsLastUpdatedKey) as? Date else {
                return nil
        }

        self._specialEvents = specialEvents
        self.specialEventsLastUpdated = specialEventsLastUpdated

        super.init(storagePath: Config.SpecialEventStoreArchive.path)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self._specialEvents, forKey: PropertyKey.specialEventsKey)
        aCoder.encode(self.specialEventsLastUpdated, forKey: PropertyKey.specialEventsLastUpdatedKey)
    }

    struct PropertyKey {
        static let specialEventsKey = "specialEvents"
        static let specialEventsLastUpdatedKey = "specialEventsLastUpdated"
    }
}

extension SpecialEventStore: FeedItemProtocol {
    func feedItems() -> [FeedItem] {
        let date = Date()
        var feedItems = [FeedItem]()

        if !PreferencesService.sharedService.showSpecialEventsInFeed {
            return feedItems
        }

        let developmentEnabled = PreferencesService.sharedService.developmentMode
        for specialEvent in self._specialEvents {
            if (((specialEvent.start as Date) <= date) && (specialEvent.end as Date >= date)) || (specialEvent.development && developmentEnabled) {
                let feedItem = FeedItem(itemType: .specialEventItem,
                                          object: specialEvent,
                                        priority: specialEvent.priority)
                feedItems.append(feedItem)
            }
        }

        return feedItems
    }
}

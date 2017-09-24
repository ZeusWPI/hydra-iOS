//
//  SpecialEventStore.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 04/04/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

let SpecialEventStoreDidUpdateNotification = "SpecialEventStoreDidUpdateNotification"

class SpecialEventStore: SavableStore, Codable {

    fileprivate static var _shared: SpecialEventStore?
    static var shared: SpecialEventStore {
        get {
            if let shared = _shared {
                return shared
            }
            // initialize new one
            _shared = SavableStore.loadStore(self, from: Config.SpecialEventStoreArchive)
            return _shared!
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
    
    override func syncStorage() {
        super.syncStorage(obj: self, storageURL: Config.SpecialEventStoreArchive)
    }

    func updateSpecialEvents(_ forced: Bool = false) {
        updateResource(APIConfig.Zeus2_0 + "association/special_events.json", notificationName: SpecialEventStoreDidUpdateNotification, lastUpdated: specialEventsLastUpdated, forceUpdate: forced) { (specialEvents: SpecialEvents) in
            self._specialEvents = specialEvents.events
            self.specialEventsLastUpdated = Date()
        }
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

        let developmentEnabled = PreferencesService.sharedService.developmentMode || true
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

fileprivate struct SpecialEvents: Codable {
    let events: [SpecialEvent]
    
    private enum CodingKeys: String, CodingKey {
        case events = "special-events"
    }
}

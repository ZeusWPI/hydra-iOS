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

    private static var _SharedStore: SpecialEventStore?
    static var sharedStore: SpecialEventStore {
        get {
            //TODO: make lazy, and catch NSKeyedUnarchiver errors
            if let _SharedStore = _SharedStore {
                return _SharedStore
            } else  {
                let specialEventStore = NSKeyedUnarchiver.unarchiveObjectWithFile(Config.AssociationStoreArchive.path!) as? SpecialEventStore
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

    private var _specialEvents: [SpecialEvent] = []
    var specialEvents: [SpecialEvent] {
        get {
            self.updateSpecialEvents()
            return _specialEvents
        }
    }

    var specialEventsLastUpdated = NSDate(timeIntervalSince1970: 0)

    init() {
        super.init(storagePath: Config.SpecialEventStoreArchive.path!)
    }

    func updateSpecialEvents(forced: Bool = false) {
        updateResource(APIConfig.Zeus2_0 + "association/special_events.json", notificationName: SpecialEventStoreDidUpdateNotification, lastUpdated: specialEventsLastUpdated, forceUpdate: forced, keyPath: "special-events") { (specialEvents: [SpecialEvent]) in
            self._specialEvents = specialEvents
            self.specialEventsLastUpdated = NSDate()
        }
    }

    // MARK: Conform to NSCoding
    required init?(coder aDecoder: NSCoder) {
        self._specialEvents = aDecoder.decodeObjectForKey(PropertyKey.specialEventsKey) as! [SpecialEvent]
        self.specialEventsLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.specialEventsLastUpdatedKey) as! NSDate

        super.init(storagePath: Config.SpecialEventStoreArchive.path!)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self._specialEvents, forKey: PropertyKey.specialEventsKey)
        aCoder.encodeObject(self.specialEventsLastUpdated, forKey: PropertyKey.specialEventsLastUpdatedKey)
    }

    struct PropertyKey {
        static let specialEventsKey = "specialEvents"
        static let specialEventsLastUpdatedKey = "specialEventsLastUpdated"
    }
}

extension SpecialEventStore: FeedItemProtocol {
    func feedItems() -> [FeedItem] {
        let date = NSDate()
        var feedItems = [FeedItem]()

        let developmentEnabled = false //TODO: add setting in NSUserDefaults

        for specialEvent in self._specialEvents {
            if ((specialEvent.start <= date) && (specialEvent.end >= date)) || (specialEvent.development && developmentEnabled)  {
                let feedItem = FeedItem(itemType: .SpecialEventItem,
                                          object: specialEvent,
                                        priority: specialEvent.priority)
                feedItems.append(feedItem)
            }
        }

        return feedItems
    }
}
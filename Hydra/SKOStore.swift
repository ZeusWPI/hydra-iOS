//
//  SKOStore.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 10/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import UIKit

let SKOStoreLineupUpdatedNotification = "SKOStoreLineupUpdated"
let SKOStoreExihibitorsUpdatedNotification = "SKOStoreExihibitorsUpdated"
let SKOStoreTimelineUpdatedNotification = "SKOStoreTimelineUpdated"
class SKOStore: SavableStore {

    private static var _SharedStore: SKOStore?
    static var sharedStore: SKOStore {
        get {
            if let _SharedStore = _SharedStore {
                return _SharedStore
            } else  {
                let skoStore = NSKeyedUnarchiver.unarchiveObjectWithFile(Config.SKOStoreArchive.path!) as? SKOStore
                if let skoStore = skoStore {
                    _SharedStore = skoStore
                    return skoStore
                }
            }
            // initialize new one
            _SharedStore = SKOStore()
            return _SharedStore!
        }
    }

    private var _lineup = [Stage]()
    private var lineupLastUpdated = NSDate(timeIntervalSince1970: 0)
    var lineup: [Stage] {
        get {
            updateLineUp()
            return _lineup
        }
    }

    private var _exihibitors = [Exihibitor]()
    private var exihibitorsLastUpdated = NSDate(timeIntervalSince1970: 0)
    var exihibitors: [Exihibitor] {
        get {
            updateExihibitors()
            return _exihibitors
        }
    }

    private var _timeline = [TimelinePost]()
    private var timelineLastUpdated = NSDate(timeIntervalSince1970: 0)
    var timeline: [TimelinePost] {
        get {
            updateTimeline()
            return _timeline
        }
    }

    init() {
        super.init(storagePath: Config.SKOStoreArchive.path!)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(storagePath: Config.SKOStoreArchive.path!)

        guard let lineup = aDecoder.decodeObjectForKey(PropertyKey.lineupKey) as? [Stage],
            let lineupLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.lineupLastUpdateKey) as? NSDate,
            let exihibitors = aDecoder.decodeObjectForKey(PropertyKey.exihibitorsKey) as? [Exihibitor],
            let exihibitorsLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.exihibitorsLastUpdatedKey) as? NSDate,
            let timeline = aDecoder.decodeObjectForKey(PropertyKey.timelineKey) as? [TimelinePost],
            let timelineLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.timelineLastUpdatedKey) as? NSDate
        else {
            return nil
        }

        self._lineup = lineup
        self.lineupLastUpdated = lineupLastUpdated
        self._exihibitors = exihibitors
        self.exihibitorsLastUpdated = exihibitorsLastUpdated
        self._timeline = timeline
        self.timelineLastUpdated = timelineLastUpdated
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(_lineup, forKey: PropertyKey.lineupKey)
        aCoder.encodeObject(lineupLastUpdated, forKey: PropertyKey.lineupLastUpdateKey)
        aCoder.encodeObject(_exihibitors, forKey: PropertyKey.exihibitorsKey)
        aCoder.encodeObject(exihibitorsLastUpdated, forKey: PropertyKey.exihibitorsLastUpdatedKey)
        aCoder.encodeObject(_timeline, forKey: PropertyKey.timelineKey)
        aCoder.encodeObject(timelineLastUpdated, forKey: PropertyKey.timelineLastUpdatedKey)
    }

    // MARK: Rest functions
    func updateLineUp(forced: Bool = false) {
        let url = APIConfig.SKO + "lineup.json"

        self.updateResource(url, notificationName: SKOStoreLineupUpdatedNotification, lastUpdated: lineupLastUpdated, forceUpdate: forced) { (lineup: [Stage]) in
            debugPrint("SKO Lineup updated")
            
            self._lineup = lineup
            self.lineupLastUpdated = NSDate()
        }
    }

    func updateExihibitors(forced: Bool = false) {
        let url = APIConfig.SKO + "student_village_exhibitors.json"

        self.updateResource(url, notificationName: SKOStoreExihibitorsUpdatedNotification, lastUpdated: exihibitorsLastUpdated, forceUpdate: forced) { (exihibitors: [Exihibitor]) in
            debugPrint("SKO Exihibitors")
            
            self._exihibitors = exihibitors
            self.exihibitorsLastUpdated = NSDate()
        }
    }

    func updateTimeline(forced: Bool = false) {
        let url = APIConfig.SKO + "timeline.json"

        self.updateResource(url, notificationName: SKOStoreTimelineUpdatedNotification, lastUpdated: timelineLastUpdated, forceUpdate: forced) { (timeline: [TimelinePost]) in
            debugPrint("SKO Timeline")

            self._timeline = timeline
            self.timelineLastUpdated = NSDate()
        }
    }

    struct PropertyKey {
        static let lineupKey = "lineup"
        static let lineupLastUpdateKey = "lineuplastupdated"
        static let exihibitorsKey = "exihibitors"
        static let exihibitorsLastUpdatedKey = "exihibitorsLastUpdated"
        static let timelineKey = "timeline"
        static let timelineLastUpdatedKey = "timelineLastUpdatedKey"
    }
}

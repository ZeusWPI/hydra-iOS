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

    fileprivate static var _SharedStore: SKOStore?
    static var sharedStore: SKOStore {
        get {
            if let _SharedStore = _SharedStore {
                return _SharedStore
            } else  {
                let skoStore = NSKeyedUnarchiver.unarchiveObject(withFile: Config.SKOStoreArchive.path) as? SKOStore
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

    fileprivate var _lineup = [Stage]()
    fileprivate var lineupLastUpdated = Date(timeIntervalSince1970: 0)
    var lineup: [Stage] {
        get {
            updateLineUp()
            return _lineup
        }
    }

    fileprivate var _exihibitors = [Exihibitor]()
    fileprivate var exihibitorsLastUpdated = Date(timeIntervalSince1970: 0)
    var exihibitors: [Exihibitor] {
        get {
            updateExihibitors()
            return _exihibitors
        }
    }

    fileprivate var _timeline = [TimelinePost]()
    fileprivate var timelineLastUpdated = Date(timeIntervalSince1970: 0)
    var timeline: [TimelinePost] {
        get {
            updateTimeline()
            return _timeline
        }
    }

    init() {
        super.init(storagePath: Config.SKOStoreArchive.path)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(storagePath: Config.SKOStoreArchive.path)

        guard let lineup = aDecoder.decodeObject(forKey: PropertyKey.lineupKey) as? [Stage],
            let lineupLastUpdated = aDecoder.decodeObject(forKey: PropertyKey.lineupLastUpdateKey) as? Date,
            let exihibitors = aDecoder.decodeObject(forKey: PropertyKey.exihibitorsKey) as? [Exihibitor],
            let exihibitorsLastUpdated = aDecoder.decodeObject(forKey: PropertyKey.exihibitorsLastUpdatedKey) as? Date,
            let timeline = aDecoder.decodeObject(forKey: PropertyKey.timelineKey) as? [TimelinePost],
            let timelineLastUpdated = aDecoder.decodeObject(forKey: PropertyKey.timelineLastUpdatedKey) as? Date
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

    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(_lineup, forKey: PropertyKey.lineupKey)
        aCoder.encode(lineupLastUpdated, forKey: PropertyKey.lineupLastUpdateKey)
        aCoder.encode(_exihibitors, forKey: PropertyKey.exihibitorsKey)
        aCoder.encode(exihibitorsLastUpdated, forKey: PropertyKey.exihibitorsLastUpdatedKey)
        aCoder.encode(_timeline, forKey: PropertyKey.timelineKey)
        aCoder.encode(timelineLastUpdated, forKey: PropertyKey.timelineLastUpdatedKey)
    }

    // MARK: Rest functions
    func updateLineUp(_ forced: Bool = false) {
        let url = APIConfig.SKO + "lineup.json"

        self.updateResource(url, notificationName: SKOStoreLineupUpdatedNotification, lastUpdated: lineupLastUpdated, forceUpdate: forced) { (lineup: [Stage]) in
            debugPrint("SKO Lineup updated")
            
            self._lineup = lineup
            self.lineupLastUpdated = Date()
        }
    }

    func updateExihibitors(_ forced: Bool = false) {
        let url = "http://studentkickoff.be/studentvillage.json"

        self.updateResource(url, notificationName: SKOStoreExihibitorsUpdatedNotification, lastUpdated: exihibitorsLastUpdated, forceUpdate: forced) { (exihibitors: [Exihibitor]) in
            debugPrint("SKO Exihibitors")
            
            self._exihibitors = exihibitors
            self.exihibitorsLastUpdated = Date()
        }
    }

    func updateTimeline(_ forced: Bool = false) {
        let url = APIConfig.SKO + "timeline.json"

        self.updateResource(url, notificationName: SKOStoreTimelineUpdatedNotification, lastUpdated: timelineLastUpdated, forceUpdate: forced) { (timeline: [TimelinePost]) in
            debugPrint("SKO Timeline")

            self._timeline = timeline
            self.timelineLastUpdated = Date()
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

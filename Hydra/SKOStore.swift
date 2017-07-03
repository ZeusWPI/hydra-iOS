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

    fileprivate static var _shared: SKOStore?
    static var shared: SKOStore {
        get {
            if let shared = _shared {
                return shared
            } /*else {
                let skoStore = NSKeyedUnarchiver.unarchiveObject(withFile: Config.SKOStoreArchive.path) as? SKOStore
                if let skoStore = skoStore {
                    _shared = skoStore
                    return skoStore
                }
            }*/
            // initialize new one
            _shared = SKOStore()
            return _shared!
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

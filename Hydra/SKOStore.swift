//
//  SKOStore.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 10/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import UIKit

let SKOStoreLineupUpdatedNotification = "SKOStoreLineupUpdated"
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

    init() {
        super.init(storagePath: Config.SKOStoreArchive.path!)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(storagePath: Config.SKOStoreArchive.path!)

        guard let lineup = aDecoder.decodeObjectForKey(PropertyKey.lineupKey) as? [Stage],
            let lineupLastUpdated = aDecoder.decodeObjectForKey(PropertyKey.lineupLastUpdateKey) as? NSDate else {
            return nil
        }

        _lineup = lineup
        self.lineupLastUpdated = lineupLastUpdated
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(_lineup, forKey: PropertyKey.lineupKey)
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


    struct PropertyKey {
        static let lineupKey = "lineup"
        static let lineupLastUpdateKey = "lineuplastupdated"
    }
}

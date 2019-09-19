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
class SKOStore: SavableStore, Codable {

    fileprivate static var _shared: SKOStore?
    static var shared: SKOStore {
        get {
            if let shared = _shared {
                return shared
            }
            // initialize new one
            _shared = SavableStore.loadStore(self, from: Config.SKOStoreArchive)
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
    
    override func syncStorage() {
        super.syncStorage(obj: self, storageURL: Config.SKOStoreArchive)
    }

    // MARK: Rest functions
    func updateLineUp(_ forced: Bool = false) {
        let url = APIConfig.SKO + "artists.json"
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.updateResource(url, notificationName: SKOStoreLineupUpdatedNotification, lastUpdated: lineupLastUpdated, forceUpdate: forced, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy.formatted(df)) { (lineup: [Artist]) in
            debugPrint("SKO Lineup updated")

            let mainStage = Stage()
            mainStage.stageName = "Main Stage"
            
            let secondStage = Stage()
            secondStage.stageName = "The Eristoff Club hosted by Moonday"
            for artist in lineup {
                if artist.stage == "Main Stage" {
                    mainStage.artists.append(artist)
                } else {
                    secondStage.artists.append(artist)
                }
            }
            self._lineup = [mainStage, secondStage]
            self.lineupLastUpdated = Date()
        }
    }

    struct PropertyKey {
        static let lineupKey = "lineup"
        static let lineupLastUpdateKey = "lineuplastupdated"
    }
}

//
//  InfoStore.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 12/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

let InfoStoreDidUpdateInfoNotification = "InfoStoreDidUpdateInfoNotification"

class InfoStore: SavableStore, Codable {
    fileprivate static var _shared: InfoStore?
    static var shared: InfoStore {
        get {
            if let shared = _shared {
                return shared
            }
            _shared = SavableStore.loadStore(self, from: Config.InfoStoreArchive)
            return _shared!
        }
    }

    fileprivate var _infoItems: [InfoItem] = []
    var infoItems: [InfoItem] {
        get {
            self.updateInfoItems()
            return self._infoItems
        }
    }

    fileprivate var infoItemsLastUpdated = Date(timeIntervalSince1970: 0)
    
    override func syncStorage() {
        super.syncStorage(obj: self, storageURL: Config.InfoStoreArchive)
    }
    
    func updateInfoItems(_ forcedUpdate: Bool = false) {
        let url = APIConfig.Zeus2_0 + "info/info-content.json"

        self.updateResource(url, notificationName: InfoStoreDidUpdateInfoNotification, lastUpdated: infoItemsLastUpdated, forceUpdate: forcedUpdate) { (items: [InfoItem]) in
            self._infoItems = items
            self.infoItemsLastUpdated = Date()
        }
    }

    struct PropertyKey {
        static let infoItemsKey = "infoItems"
        static let infoItemsLastUpdatedKey = "infoItemsLastUpdated"
    }
}

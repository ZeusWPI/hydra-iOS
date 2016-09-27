//
//  InfoStore.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 12/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

let InfoStoreDidUpdateInfoNotification = "InfoStoreDidUpdateInfoNotification"

class InfoStore: SavableStore, NSCoding {
    fileprivate static var _SharedStore: InfoStore?
    static var sharedStore: InfoStore {
        get {
            if let _SharedStore = _SharedStore {
                return _SharedStore
            } else  {
                let infoStore = NSKeyedUnarchiver.unarchiveObject(withFile: Config.InfoStoreArchive.path) as? InfoStore
                if let infoStore = infoStore {
                    _SharedStore = infoStore
                    return _SharedStore!
                }
            }
            // initialize new one
            _SharedStore = InfoStore()
            return _SharedStore!
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

    init() {
        super.init(storagePath: Config.InfoStoreArchive.path)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self._infoItems = aDecoder.decodeObject(forKey: PropertyKey.infoItemsKey) as! [InfoItem]
        self.infoItemsLastUpdated = aDecoder.decodeObject(forKey: PropertyKey.infoItemsLastUpdatedKey) as! Date
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self._infoItems, forKey: PropertyKey.infoItemsKey)
        aCoder.encode(self.infoItemsLastUpdated, forKey: PropertyKey.infoItemsLastUpdatedKey)
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

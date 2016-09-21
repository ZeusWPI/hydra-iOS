//
//  Stage.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 10/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import ObjectMapper

class Stage: NSObject, NSCoding, Mappable {
    var stageName: String = ""
    var artists: [Artist] = []

    required init?(_ map: Map) {

    }

    required init?(coder aDecoder: NSCoder) {
        guard let stageName = aDecoder.decodeObjectForKey(PropertyKey.stageNameKey) as? String,
            let artists = aDecoder.decodeObjectForKey(PropertyKey.artistsKey) as? [Artist] else {
                return nil
        }

        self.stageName = stageName
        self.artists = artists
    }

    func mapping(map: Map) {
        stageName <- map[PropertyKey.stageNameKey]
        artists <- map[PropertyKey.artistsKey]
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(stageName, forKey: PropertyKey.stageNameKey)
        aCoder.encodeObject(artists, forKey: PropertyKey.artistsKey)
    }

    struct PropertyKey {
        static let stageNameKey = "stage"
        static let artistsKey = "artists"
    }
}

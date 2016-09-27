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

    required init?(map: Map) {

    }

    required init?(coder aDecoder: NSCoder) {
        guard let stageName = aDecoder.decodeObject(forKey: PropertyKey.stageNameKey) as? String,
            let artists = aDecoder.decodeObject(forKey: PropertyKey.artistsKey) as? [Artist] else {
                return nil
        }

        self.stageName = stageName
        self.artists = artists
    }

    func mapping(map: Map) {
        stageName <- map[PropertyKey.stageNameKey]
        artists <- map[PropertyKey.artistsKey]
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(stageName, forKey: PropertyKey.stageNameKey)
        aCoder.encode(artists, forKey: PropertyKey.artistsKey)
    }

    struct PropertyKey {
        static let stageNameKey = "stage"
        static let artistsKey = "artists"
    }
}

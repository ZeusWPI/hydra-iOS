//
//  Exihibitor.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import ObjectMapper

class Exihibitor: NSObject, NSCoding, Mappable {

    var name: String = ""

    required init?(_ map: Map) {
    }

    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as? String else { return nil }

        self.name = name
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
    }

    func mapping(map: Map) {
        name <- map[PropertyKey.nameKey]
    }

    struct PropertyKey {
        static let nameKey = "name"
    }
}
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
    var content: String = ""
    var logo: String = ""

    required init?(_ map: Map) {
    }

    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as? String,
            let content = aDecoder.decodeObjectForKey(PropertyKey.contentKey) as? String,
            let logo = aDecoder.decodeObjectForKey(PropertyKey.logoKey) as? String
        else { return nil }

        self.name = name
        self.content = content
        self.logo = logo
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(content, forKey: PropertyKey.contentKey)
        aCoder.encodeObject(logo, forKey: PropertyKey.logoKey)
    }

    func mapping(map: Map) {
        name <- map["naam"]
        content <- map[PropertyKey.contentKey]
        logo <- map[PropertyKey.logoKey]
    }

    struct PropertyKey {
        static let nameKey = "name"
        static let contentKey = "content"
        static let logoKey = "logo"
    }
}
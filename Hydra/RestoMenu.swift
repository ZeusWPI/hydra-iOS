//
//  RestoMenu.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 02/03/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper

class RestoMenu: NSObject, NSCoding, Mappable {

    var date: NSDate
    var meals: [RestoMenuItem]?
    var open: Bool = false
    var vegetables: [String] = []
    var lastUpdated = NSDate()


    required init?(_ map: Map) {
        date = NSDate().dateAtStartOfDay()
    }

    init(date: NSDate, open: Bool) {
        self.date = date
        self.open = open
    }

    func mapping(map: Map) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.date <- (map[PropertyKey.dateKey], DateFormatterTransform(dateFormatter: formatter))
        self.meals <- map[PropertyKey.mealsKey]
        self.open <- map[PropertyKey.openKey]
        self.vegetables <- map[PropertyKey.vegetablesKey]
    }

    // MARK: implement NSCoding protocol
    required init?(coder aDecoder: NSCoder) {
        self.date = aDecoder.decodeObjectForKey(PropertyKey.dateKey) as! NSDate
        self.meals = aDecoder.decodeObjectForKey(PropertyKey.mealsKey) as? [RestoMenuItem]
        self.open = aDecoder.decodeObjectForKey(PropertyKey.openKey) as! Bool
        self.vegetables = aDecoder.decodeObjectForKey(PropertyKey.vegetablesKey) as! [String]
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(date, forKey: PropertyKey.dateKey)
        aCoder.encodeObject(meals, forKey: PropertyKey.mealsKey)
        aCoder.encodeObject(open, forKey: PropertyKey.openKey)
        aCoder.encodeObject(vegetables, forKey: PropertyKey.vegetablesKey)
        aCoder.encodeObject(lastUpdated, forKey: PropertyKey.lastUpdatedKey)
    }

    struct PropertyKey {
        static let dateKey = "date"
        static let openKey = "open"
        static let mealsKey = "meals"
        static let vegetablesKey = "vegetables"
        static let lastUpdatedKey = "lastUpdated"
    }
}

class RestoMenuItem: NSObject, NSCoding, Mappable {
    var kind: String? // TODO: make enum or something
    var name: String
    var price: String?
    var type: String //TODO: make enum or something

    // MARK: implement mapping protocol
    required init?(_ map: Map) {
        self.name = ""
        self.type = ""
    }

    func mapping(map: Map) {
        self.kind <- map[PropertyKey.kindKey]
        self.name <- map[PropertyKey.nameKey]
        self.price <- map[PropertyKey.priceKey]
        self.type <- map[PropertyKey.typeKey]
    }

    // MARK: implement NSCoding protocol
    required init?(coder aDecoder: NSCoder) {
        kind = aDecoder.decodeObjectForKey(PropertyKey.kindKey) as? String
        name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        price = aDecoder.decodeObjectForKey(PropertyKey.priceKey) as? String
        type = aDecoder.decodeObjectForKey(PropertyKey.typeKey) as! String
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(kind, forKey: PropertyKey.kindKey)
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(price, forKey: PropertyKey.priceKey)
        aCoder.encodeObject(type, forKey: PropertyKey.typeKey)
    }

    struct PropertyKey {
        static let kindKey = "kind"
        static let nameKey = "name"
        static let priceKey = "price"
        static let typeKey = "type"
    }
}
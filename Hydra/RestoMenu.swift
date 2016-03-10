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

    var sideDishes: [RestoMenuItem]? {
        //TODO: cache...
        return meals?.filter({ $0.type == .Side })
    }

    var mainDishes: [RestoMenuItem]? {
        //TODO: cache...
        return meals?.filter({ $0.type != .Side})
    }

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
    var kind: RestoMenuKind = .Other
    var name: String
    var price: String?
    var type: RestoMenuType = .Other

    // MARK: implement mapping protocol
    required init?(_ map: Map) {
        self.name = ""
    }

    func mapping(map: Map) {
        let menuKindTransform = TransformOf<RestoMenuKind, String>(fromJSON: { (jsonString) -> RestoMenuKind in
            if let jsonString = jsonString {
                return self.restoMenuKindFromString(jsonString)
            }
            return .Other
        }) { (menuKind) -> String? in
            return menuKind?.rawValue
        }


        let restoTypeTransform = TransformOf<RestoMenuType, String>(fromJSON: { (jsonString) -> RestoMenuType in
            if let jsonString = jsonString {
                return self.restoMenuTypeFromString(jsonString)
            }
            return .Other
        }) { (restoType) -> String? in
            return restoType?.rawValue
        }

        self.kind <- (map[PropertyKey.kindKey], menuKindTransform)
        self.name <- map[PropertyKey.nameKey]
        self.price <- map[PropertyKey.priceKey]
        self.type <- (map[PropertyKey.typeKey], restoTypeTransform)
    }

    // MARK: implement NSCoding protocol
    required init?(coder aDecoder: NSCoder) {
        kind = RestoMenuKind.init(rawValue: aDecoder.decodeObjectForKey(PropertyKey.kindKey) as! String)!
        name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        price = aDecoder.decodeObjectForKey(PropertyKey.priceKey) as? String
        type = RestoMenuType.init(rawValue: aDecoder.decodeObjectForKey(PropertyKey.typeKey) as! String)!
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(kind.rawValue, forKey: PropertyKey.kindKey)
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(price, forKey: PropertyKey.priceKey)
        aCoder.encodeObject(type.rawValue, forKey: PropertyKey.typeKey)
    }

    private func restoMenuTypeFromString(type: String) -> RestoMenuType {
        var restoType = RestoMenuType.init(rawValue: type)
        if restoType == nil {
            restoType = .Some(.Other)
        }
        return restoType!
    }

    private func restoMenuKindFromString(kind: String) -> RestoMenuKind {
        var restoKind = RestoMenuKind.init(rawValue: kind)
        if restoKind == nil {
            restoKind = .Some(.Other)
        }
        return restoKind!
    }

    struct PropertyKey {
        static let kindKey = "kind"
        static let nameKey = "name"
        static let priceKey = "price"
        static let typeKey = "type"
    }
}

enum RestoMenuType: String {
    case Side = "side"
    case Main = "main"
    case Other = "other"
}

enum RestoMenuKind: String {
    case Soup = "soup"
    case Meat = "meat"
    case Vegetarian = "vegetarian"
    case Fish = "fish"
    case Other = "other"
}
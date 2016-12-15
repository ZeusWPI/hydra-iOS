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

    var date: Date
    var meals: [RestoMenuItem]?
    var open: Bool
    var vegetables: [String]?
    var lastUpdated: Date?

    var sideDishes: [RestoMenuItem]? {
        //TODO: cache...
        return meals?.filter({ $0.type == .Side })
    }

    var mainDishes: [RestoMenuItem]? {
        //TODO: cache...
        return meals?.filter({ $0.type != .Side})
    }

    required convenience init?(map: Map) {
        self.init(date: NSDate().atStartOfDay())
    }

    init(date: Date, meals: [RestoMenuItem]? = nil, open: Bool = false, vegetables: [String]? = nil, lastUpdated: Date? = nil) {
        self.date = date
        self.meals = meals
        self.open = open
        self.vegetables = vegetables
        self.lastUpdated = lastUpdated
    }

    func mapping(map: Map) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.date <- (map[PropertyKey.dateKey], DateFormatterTransform(dateFormatter: formatter))
        self.meals <- map[PropertyKey.mealsKey]
        self.open <- map[PropertyKey.openKey]
        self.vegetables <- map[PropertyKey.vegetablesKey]
    }

    // MARK: implement NSCoding protocol
    required convenience init?(coder aDecoder: NSCoder) {
        guard let date = aDecoder.decodeObject(forKey: PropertyKey.dateKey) as? Date,
            let vegetables = aDecoder.decodeObject(forKey: PropertyKey.vegetablesKey) as? [String]
            else {return nil}

        let open = aDecoder.decodeBool(forKey: PropertyKey.openKey)
        let lastUpdated = aDecoder.decodeObject(forKey: PropertyKey.dateKey) as? Date
        let meals = aDecoder.decodeObject(forKey: PropertyKey.mealsKey) as? [RestoMenuItem]

        self.init(date: date, meals: meals, open: open, vegetables: vegetables, lastUpdated: lastUpdated)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: PropertyKey.dateKey)
        aCoder.encode(meals, forKey: PropertyKey.mealsKey)
        aCoder.encode(open, forKey: PropertyKey.openKey)
        aCoder.encode(vegetables, forKey: PropertyKey.vegetablesKey)
        aCoder.encode(lastUpdated, forKey: PropertyKey.lastUpdatedKey)
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
    var kind: RestoMenuKind
    var name: String
    var price: String?
    var type: RestoMenuType

    // MARK: implement mapping protocol
    required convenience init?(map: Map) {
        self.init(name: "")
    }

    init(name: String, price: String? = nil, kind: RestoMenuKind = .Other, type: RestoMenuType = .Other) {
        self.name = name
        self.price = price
        self.kind = kind
        self.type = type
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
    required convenience init?(coder aDecoder: NSCoder) {
        guard let kindString = aDecoder.decodeObject(forKey: PropertyKey.kindKey) as? String,
            let kind = RestoMenuKind.init(rawValue: kindString),
            let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as? String,
            let typeString = aDecoder.decodeObject(forKey: PropertyKey.typeKey) as? String,
            let type = RestoMenuType.init(rawValue: typeString)
            else { return nil }

        let price = aDecoder.decodeObject(forKey: PropertyKey.priceKey) as? String

        self.init(name: name, price: price, kind: kind, type: type)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(kind.rawValue, forKey: PropertyKey.kindKey)
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(price, forKey: PropertyKey.priceKey)
        aCoder.encode(type.rawValue, forKey: PropertyKey.typeKey)
    }

    fileprivate func restoMenuTypeFromString(_ type: String) -> RestoMenuType {
        var restoType = RestoMenuType.init(rawValue: type)
        if restoType == nil {
            restoType = .some(.Other)
        }
        return restoType!
    }

    fileprivate func restoMenuKindFromString(_ kind: String) -> RestoMenuKind {
        var restoKind = RestoMenuKind.init(rawValue: kind)
        if restoKind == nil {
            restoKind = .some(.Other)
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

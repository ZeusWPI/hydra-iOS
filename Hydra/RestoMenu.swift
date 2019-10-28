//
//  RestoMenu.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 02/03/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class RestoMenu: NSObject, Codable {

    var message: String?
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

    init(message: String? = nil, date: Date, meals: [RestoMenuItem]? = nil, open: Bool = false, vegetables: [String]? = nil, lastUpdated: Date? = nil) {
        self.message = message
        self.date = date
        self.meals = meals
        self.open = open
        self.vegetables = vegetables
        self.lastUpdated = lastUpdated
    }

    //TODO: formatter.dateFormat = "yyyy-MM-dd"
    
    private enum CodingKeys: String, CodingKey {
        case message, date, open, meals, vegetables, lastUpdated
    }
}

class RestoMenuItem: NSObject, Codable {
    // TODO: fix with manual coding
    var kindVar: String?
    
    var kind: RestoMenuKind {
        get {
            if let kind = kindVar {
                if let k = RestoMenuKind(rawValue: kind) {
                    return k
                }
            }
            return .Other
        }
    }
    var name: String
    var price: String?
    var typeVar: String?
    
    var type: RestoMenuType {
        get {
            if let type = typeVar {
                if let t = RestoMenuType(rawValue: type) {
                    return t
                }
            }
            return .Other
        }
    }

    init(name: String, price: String? = nil, kind: RestoMenuKind = .Other, type: RestoMenuType = .Other) {
        self.name = name
        self.price = price
        self.kindVar = kind.rawValue
        self.typeVar = type.rawValue
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

    private enum CodingKeys: String, CodingKey {
        case name, price, typeVar = "type", kindVar = "kind"
    }
}

enum RestoMenuType: String, Codable {
    case Side = "side"
    case Main = "main"
    case Other = "other"
}

enum RestoMenuKind: String, Codable {
    case Soup = "soup"
    case Meat = "meat"
    case Vegetarian = "vegetarian"
    case Vegan = "vegan"
    case Fish = "fish"
    case Other = "other"
}

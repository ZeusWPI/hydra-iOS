//
//  RestoMenu.swift
//  Hydra
//
//  Created by Ieben Smessaert on 27/01/2023.
//  Copyright © 2023 Zeus WPI. All rights reserved.
//

import Foundation

struct RestoMenu: Decodable {
    let message: String?
    let date: Date
    let meals: [RestoMenuItem]
    let open: Bool
    let vegetables: [String]
    var lastUpdated: Date?
    
    private enum CodingKeys: String, CodingKey {
        case message, date, meals, open, vegetables, lastUpdated
    }
}

struct RestoMenuItem: Decodable, Hashable {

    let kindVar: String?
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

    let name: String
    let price: String?

    let typeVar: String?
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

    private enum CodingKeys: String, CodingKey {
        case name, price, typeVar = "type", kindVar = "kind"
    }
}

enum RestoMenuType: String, Codable {
    case Side = "side"
    case Main = "main"
    case Cold = "cold"
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

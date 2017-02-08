//
//  RestoSandwiches.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/2015.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper

@objc class RestoSandwich: NSObject, NSCoding, Mappable {
    var name: String
    var ingredients: [String]
    var priceSmall: String
    var priceMedium: String

    override convenience init() {
        self.init(name: "", ingredients: [], priceSmall: "", priceMedium: "")
    }

    init(name: String, ingredients: [String], priceSmall: String, priceMedium: String) {
        self.name = name
        self.ingredients = ingredients
        self.priceSmall = priceSmall
        self.priceMedium = priceMedium
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        self.name <- map[PropertyKey.nameKey]
        self.ingredients <- map[PropertyKey.ingredientsKey]
        self.priceSmall <- map["price_small"]
        self.priceMedium <- map["price_medium"]
    }

    // MARK: NSCoding
    required convenience init?(coder decoder: NSCoder) {
        guard let name = decoder.decodeObject(forKey: PropertyKey.nameKey) as? String,
              let ingredients = decoder.decodeObject(forKey: PropertyKey.ingredientsKey) as? [String],
              let priceSmall = decoder.decodeObject(forKey: PropertyKey.priceSmallKey) as? String,
              let priceMedium = decoder.decodeObject(forKey: PropertyKey.priceMediumKey) as? String
            else {return nil}

        self.init(name: name, ingredients: ingredients, priceSmall: priceSmall, priceMedium: priceMedium)
    }

    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: PropertyKey.nameKey)
        coder.encode(ingredients, forKey: PropertyKey.ingredientsKey)
        coder.encode(priceSmall, forKey: PropertyKey.priceSmallKey)
        coder.encode(priceMedium, forKey: PropertyKey.priceMediumKey)
    }

    struct PropertyKey {
        static let nameKey = "name"
        static let ingredientsKey = "ingredients"
        static let priceSmallKey = "priceSmall"
        static let priceMediumKey = "priceMedium"
    }
}

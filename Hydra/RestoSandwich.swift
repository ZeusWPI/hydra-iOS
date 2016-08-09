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

    required convenience init?(_ map: Map) {
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
        guard let name = decoder.decodeObjectForKey(PropertyKey.nameKey) as? String,
              let ingredients = decoder.decodeObjectForKey(PropertyKey.ingredientsKey) as? [String],
              let priceSmall = decoder.decodeObjectForKey(PropertyKey.priceSmallKey) as? String,
              let priceMedium = decoder.decodeObjectForKey(PropertyKey.priceMediumKey) as? String
            else {return nil}
        
        self.init(name: name, ingredients: ingredients, priceSmall: priceSmall, priceMedium: priceMedium)
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(name, forKey: PropertyKey.nameKey)
        coder.encodeObject(ingredients, forKey: PropertyKey.ingredientsKey)
        coder.encodeObject(priceSmall, forKey: PropertyKey.priceSmallKey)
        coder.encodeObject(priceMedium, forKey: PropertyKey.priceMediumKey)
    }

    struct PropertyKey {
        static let nameKey = "name"
        static let ingredientsKey = "ingredients"
        static let priceSmallKey = "priceSmall"
        static let priceMediumKey = "priceMedium"
    }
}
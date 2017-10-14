//
//  RestoSandwiches.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/2015.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation

@objc class RestoSandwich: NSObject, Codable {
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

    private enum CodingKeys: String, CodingKey {
        case name, ingredients
        case priceSmall = "price_small"
        case priceMedium = "price_medium"
    }
}

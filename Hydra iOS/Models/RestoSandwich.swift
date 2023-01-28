//
//  RestoSandwich.swift
//  Hydra
//
//  Created by Ieben Smessaert on 28/01/2023.
//  Copyright © 2023 Zeus WPI. All rights reserved.
//

import Foundation

struct RestoSandwich: Decodable, Hashable {
    let name: String
    let price: String
    let ingredients: [String]
    
    private enum CodingKeys: String, CodingKey {
        case name, ingredients
        case price = "price_medium"
    }
}

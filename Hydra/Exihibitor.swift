//
//  Exihibitor.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

class Exihibitor: NSObject, Codable {

    var name: String = ""
    var content: String = ""
    var logo: String = ""

    private enum CodingKeys: String, CodingKey {
        case content, logo
        case name = "naam"
    }
}

//
//  Stage.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 10/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import ObjectMapper

class Stage: NSObject, Codable {
    var stageName: String = ""
    var artists: [Artist] = []

    private enum CodingKeys: String, CodingKey {
        case stageName = "stage"
        case artists
    }
}
